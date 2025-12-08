/* background.js
   Phase 1 image cycler (default: shuffle mode)
   - Looks for images in /static/images/backgrounds named image1.jpg ... imageN.jpg
   - Configurable: mode ('shuffle'|'sequential'), intervalMs, fadeMs, imagesCount, filename pattern
*/

(function () {
  const config = {
    mode: 'shuffle',       // 'shuffle' or 'sequential' - default is shuffle as you requested
    intervalMs: 9000,      // time between transitions
    fadeMs: 1200,          // crossfade duration
    imagesCount: 10,       // how many image files to try (image1..image10)
    prefix: '/static/images/backgrounds/image', // prefix for files
    ext: '.jpg',           // extension
    resumeFromLocalStorage: true, // store last index for illusion of continuity across reloads
  };

  // helper - shuffle array in place (Fisher-Yates)
  function shuffleArray(a) {
    for (let i = a.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [a[i], a[j]] = [a[j], a[i]];
    }
  }

  // preload helper returns Promise for {url, ok}
  function preload(url) {
    return new Promise((resolve) => {
      const img = new Image();
      img.onload = () => resolve({ url, ok: true });
      img.onerror = () => resolve({ url, ok: false });
      img.src = url;
    });
  }

  // Build candidate urls and preload them
  async function gatherImages() {
    const candidates = [];
    for (let i = 1; i <= config.imagesCount; i++) {
      candidates.push(`${config.prefix}${i}${config.ext}`);
    }

    const results = await Promise.all(candidates.map(preload));
    const ok = results.filter(r => r.ok).map(r => r.url);
    return ok;
  }

  // Create DOM slide elements (two-layer crossfade)
  function createSlides(container) {
    const slideA = document.createElement('div');
    const slideB = document.createElement('div');
    slideA.className = 'bg-slide';
    slideB.className = 'bg-slide';
    container.appendChild(slideA);
    container.appendChild(slideB);
    return [slideA, slideB];
  }

  function startCycler(images) {
    if (!images || images.length === 0) {
      console.warn('No background images found. Background cycler will not start.');
      return;
    }

    // apply fade duration to CSS variable
    document.documentElement.style.setProperty('--bg-fade-duration', config.fadeMs + 'ms');

    const container = document.getElementById('bg-root');
    if (!container) {
      console.error('No #bg-root element found in DOM.');
      return;
    }

    const [slideA, slideB] = createSlides(container);
    let currentIndex = 0;
    let order = images.slice();

    if (config.mode === 'shuffle') {
      shuffleArray(order);
    }

    // resume index if desired
    if (config.resumeFromLocalStorage) {
      try {
        const saved = Number(localStorage.getItem('ats_bg_index')) || 0;
        if (!Number.isNaN(saved) && saved < order.length) currentIndex = saved;
      } catch (e) { /* ignore */ }
    }

    // initialize first slide
    slideA.style.backgroundImage = `url('${order[currentIndex]}')`;
    slideA.classList.add('visible');
    slideB.classList.remove('visible');

    let showingA = true;

    function pickNextIndex() {
      if (config.mode === 'shuffle') {
        // increment; if at end, reshuffle and start at 0
        currentIndex++;
        if (currentIndex >= order.length) {
          shuffleArray(order);
          currentIndex = 0;
        }
      } else {
        currentIndex = (currentIndex + 1) % order.length;
      }
      // persist
      try { localStorage.setItem('ats_bg_index', String(currentIndex)); } catch (e) {}
      return currentIndex;
    }

    let intervalId = null;

    function doTransition() {
      const nextIndex = pickNextIndex();
      const nextUrl = order[nextIndex];
      const incoming = showingA ? slideB : slideA;
      const outgoing = showingA ? slideA : slideB;

      // set incoming image then fade it in
      incoming.style.backgroundImage = `url('${nextUrl}')`;
      // trigger reflow then apply visible class
      void incoming.offsetWidth;
      incoming.classList.add('visible');

      // remove visible from outgoing after fade time (so crossfade happens)
      setTimeout(() => {
        outgoing.classList.remove('visible');
      }, config.fadeMs);

      showingA = !showingA;
    }

    // start interval
    intervalId = setInterval(doTransition, config.intervalMs);

    // Pause when page not visible
    document.addEventListener('visibilitychange', () => {
      if (document.hidden) {
        if (intervalId) { clearInterval(intervalId); intervalId = null; }
      } else {
        if (!intervalId) intervalId = setInterval(doTransition, config.intervalMs);
      }
    }, false);
  }

  // bootstrap
  (async function init() {
    const images = await gatherImages();
    if (images.length === 0) {
      console.warn('Background cycler: no images found in configured path.');
      return;
    }
    startCycler(images);
  })();

  // expose a small API for toggling modes from console if needed
  window.ATSBackground = {
    setMode: (m) => { if (m === 'shuffle' || m === 'sequential') { config.mode = m; localStorage.setItem('ats_bg_mode', m); } },
  };
})();
