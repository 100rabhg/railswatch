const STORAGE_KEY = 'railswatch:theme';

function preferredTheme() {
  try {
    const savedTheme = localStorage.getItem(STORAGE_KEY);
    if (savedTheme === 'light' || savedTheme === 'dark') return savedTheme;
  } catch (_error) {
    return 'light';
  }

  return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
}

function syncThemeButtons(theme) {
  document.querySelectorAll('[data-theme-label]').forEach((label) => {
    label.textContent = theme === 'dark' ? 'Dark' : 'Light';
  });
}

function applyTheme(theme) {
  document.documentElement.dataset.theme = theme;
  try {
    localStorage.setItem(STORAGE_KEY, theme);
  } catch (_error) {
    // no-op
  }
  syncThemeButtons(theme);
  window.dispatchEvent(new CustomEvent('railswatch:theme-change', { detail: { theme } }));
}

function initializeThemeToggle() {
  syncThemeButtons(preferredTheme());

  document.addEventListener('click', (event) => {
    const toggle = event.target.closest('[data-theme-toggle]');
    if (!toggle) return;

    const currentTheme = document.documentElement.dataset.theme || preferredTheme();
    applyTheme(currentTheme === 'dark' ? 'light' : 'dark');
  });
}

document.addEventListener('DOMContentLoaded', initializeThemeToggle);
