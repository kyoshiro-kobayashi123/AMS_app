document.addEventListener('DOMContentLoaded', function() {
  const ham = document.getElementById('js-hamburger');
  const nav = document.getElementById('js-nav');
  const text = ham.querySelector('.hamburger__text');

  if (ham && nav) {
    ham.addEventListener('click', function () {
      // クラスの付け外し
      ham.classList.toggle('active');
      nav.classList.toggle('active');

      // テキストの切り替え
      if (ham.classList.contains('active')) {
        text.textContent = 'CLOSE';
      } else {
        text.textContent = 'MENU';
      }
    });
  }
});
