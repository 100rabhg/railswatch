document.addEventListener('click', (event) => {
  const toggle = event.target.closest('[data-nav-toggle]');
  if (!toggle) return;

  const topbar = toggle.closest('.rm-topbar');
  const nav = topbar?.querySelector('#railswatch-nav');
  if (!topbar || !nav) return;

  const isOpen = topbar.classList.toggle('is-nav-open');
  toggle.setAttribute('aria-expanded', String(isOpen));
});
