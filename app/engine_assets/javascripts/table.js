import $ from 'jquery';
window.jQuery = $; // shim for stupid-table-plugin
await import('stupid-table-plugin');

function initializeTables() {
  $('table').stupidtable();
}

window.initializeRailswatchTables = initializeTables;

$(initializeTables);
document.addEventListener('railswatch:content-updated', initializeTables);
