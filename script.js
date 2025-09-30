function createRain() {
  // هدف‌گیری فقط بخش سمت راست
  const main = document.getElementById('rain-container');
  const screenWidth = main.offsetWidth; // عرض بخش افکت باران
  const numCols = Math.floor(screenWidth / 60);

  for (let i = 0; i < numCols; i++) {
    const col = document.createElement('div');
    col.className = 'column';
    col.style.left = `${i * 60}px`;
    col.style.animationDuration = `${5 + Math.random() * 5}s`;
    col.style.animationDelay = `${Math.random() * 5}s`;

    const word = "ZENCHAIN";
    for (let char of word) {
      const span = document.createElement('span');
      span.className = 'letter';
      span.textContent = char;
      col.appendChild(span);
    }

    // اضافه کردن ستون‌ها به کانتینر باران
    main.appendChild(col);
  }
}

createRain();
