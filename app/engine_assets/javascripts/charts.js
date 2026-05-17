import ApexCharts from "railswatch/apex_ext";
import ms from "ms";

class RailswatchChart extends HTMLElement {
  connectedCallback() {
    this.legend = this.getAttribute('legend');
    this.units = this.getAttribute('units');
    this.type = this.getAttribute('type');
    this.dataText = this.textContent.trim();
    this.handleThemeChange = () => this.rebuildChart();
    this.chart = this.buildChart();
    this.observeDataChanges();
    window.addEventListener('railswatch:theme-change', this.handleThemeChange);
  }

  disconnectedCallback() {
    this.mutationObserver?.disconnect();
    window.removeEventListener('railswatch:theme-change', this.handleThemeChange);
    this.chart?.destroy();
  }

  buildChart() {
    this.chart?.destroy();

    if (!this.shadowRoot) {
      this.attachShadow({ mode: 'open' });
    }

    const chartDiv = document.createElement('div');
    this.shadowRoot.innerHTML = '';
    this.shadowRoot.appendChild(chartDiv);

    const data = this.safeParseJson(this.dataText);
    const renderMethod = this[`render${this.type}Chart`];
    return renderMethod.call(this, chartDiv, data);
  }

  rebuildChart() {
    this.chart = this.buildChart();
  }

  safeParseJson(text, defaultValue = []) {
    try {
      return JSON.parse(text);
    } catch (_error) {
      return defaultValue;
    }
  }

  observeDataChanges() {
    this.mutationObserver = new MutationObserver(() => {
      const currentText = this.textContent.trim();
      if (currentText === this.dataText) return;
      this.dataText = currentText;
      const data = this.safeParseJson(currentText);
      this.updateChart(data);
    });
    this.mutationObserver.observe(this, { childList: true, characterData: true, subtree: true });
  }

  updateChart(newData) {
    let incoming = newData;
    if (this.type === 'Usage') {
      const { bytes } = calculateByteUnit(newData);
      incoming = newData.map(([timestamp, value]) => [timestamp, typeof value === 'number' ? (value / bytes).toFixed(2) : null]);
    }
    this.chart.updateRollingWindow(incoming, { windowSizeMs: this.windowSizeMs });
  }

  get windowSizeMs() {
    if (this.type === 'TIR' || this.type === 'RT') {
      return window.railswatchDuration || ms("4h");
    }

    return ms("24h");
  }

  renderTIRChart(element, data) {
    return renderChart(element, data, {
      chartType: 'area',
      yAxisTitle: 'RPM',
      seriesName: this.legend,
      units: this.units,
      colorKey: 'accent2'
    });
  }

  renderRTChart(element, data) {
    return renderChart(element, data, {
      chartType: 'area',
      yAxisTitle: 'Time',
      seriesName: 'Response Time',
      units: 'ms',
      colorKey: 'accent'
    });
  }

  renderPercentageChart(element, data) {
    return renderChart(element, data, {
      chartType: 'line',
      yAxisTitle: '%',
      seriesName: this.legend,
      units: '%',
      colorKey: 'warning'
    });
  }

  renderUsageChart(element, data) {
    const { units, bytes } = calculateByteUnit(data);
    return renderChart(element, data, {
      chartType: 'line',
      yAxisTitle: this.legend,
      seriesName: this.legend,
      units: units,
      colorKey: 'accent',
      dataTransform: (points) => {
        return points.map(([timestamp, value]) => [timestamp, typeof value === 'number' ? (value / bytes).toFixed(2) : null]);
      }
    });
  }
}

customElements.define('railswatch-chart', RailswatchChart);

function calculateByteUnit(data) {
  let max = data.reduce((accumulator, [_timestamp, value]) => (value > accumulator ? value : accumulator), -Infinity);
  let power = 0;
  while (max >= 1024 && power < 5) {
    max /= 1024;
    power += 1;
  }

  const units = ['bytes', 'KB', 'MB', 'GB', 'TB', 'PB'][power];
  const bytes = Math.pow(1024, power);

  return { units, bytes };
}

function themePalette() {
  const styles = getComputedStyle(document.documentElement);
  const theme = document.documentElement.dataset.theme || 'light';

  return {
    theme,
    fontFamily: styles.getPropertyValue('--rm-font-body').trim() || 'sans-serif',
    text: styles.getPropertyValue('--rm-chart-text').trim() || '#64748b',
    grid: styles.getPropertyValue('--rm-chart-grid').trim() || 'rgba(148, 163, 184, 0.16)',
    surface: styles.getPropertyValue('--rm-chart-surface').trim() || '#ffffff',
    accent: styles.getPropertyValue('--rm-accent').trim() || '#0f766e',
    accent2: styles.getPropertyValue('--rm-accent-2').trim() || '#2563eb',
    warning: styles.getPropertyValue('--rm-warning').trim() || '#d97706'
  };
}

function renderChart(element, data, { chartType = 'area', yAxisTitle, seriesName, units, colorKey = 'accent', dataTransform = (points) => points } = {}) {
  const palette = themePalette();
  const color = palette[colorKey] || palette.accent;

  const chart = new ApexCharts(element, {
    chart: {
      type: chartType,
      height: 320,
      width: '100%',
      id: `chart-${Math.random().toFixed(10)}`,
      group: 'chart',
      fontFamily: palette.fontFamily,
      toolbar: {
        show: false
      },
      zoom: {
        type: 'x'
      },
      animations: {
        easing: 'easeinout',
        speed: 450
      },
      background: 'transparent'
    },
    colors: [color],
    stroke: {
      width: chartType === 'area' ? 2.8 : 2.4,
      curve: 'smooth'
    },
    fill: chartType === 'area' ? {
      type: 'gradient',
      gradient: {
        opacityFrom: 0.28,
        opacityTo: 0.02,
        shadeIntensity: 0.8
      }
    } : {
      opacity: 1
    },
    grid: {
      borderColor: palette.grid,
      strokeDashArray: 4,
      padding: {
        left: 4,
        right: 8
      }
    },
    markers: {
      size: 0,
      hover: {
        size: 5
      }
    },
    dataLabels: {
      enabled: false
    },
    legend: {
      show: false
    },
    xaxis: {
      crosshairs: {
        show: true,
        stroke: {
          color: palette.grid
        }
      },
      type: 'datetime',
      labels: {
        datetimeUTC: false,
        style: {
          colors: [palette.text]
        }
      },
      axisBorder: {
        color: palette.grid
      },
      axisTicks: {
        color: palette.grid
      }
    },
    yaxis: {
      min: 0,
      title: {
        text: yAxisTitle,
        style: {
          color: palette.text,
          fontWeight: 600
        }
      },
      labels: {
        style: {
          colors: [palette.text]
        }
      }
    },
    tooltip: {
      theme: palette.theme,
      style: {
        fontSize: '13px',
        fontFamily: palette.fontFamily
      },
      marker: {
        show: false
      },
      x: {
        show: true,
        format: 'dd MMM yyyy HH:mm'
      },
      y: {
        formatter: (value) => value ? `${value} ${units}`.trim() : undefined,
        title: {
          formatter: () => ''
        }
      }
    },
    series: [{
      name: seriesName,
      data: dataTransform(data)
    }],
    annotations: window?.annotationsData || {}
  });

  chart.render();
  return chart;
}
