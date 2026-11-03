(function () {
    "use strict";

    const root = document.getElementById("tourRecommendation");
    if (!root) return;

    const slides = Array.from(root.querySelectorAll(".tour-slide"));
    const prevButton = document.getElementById("tourPrevButton");
    const nextButton = document.getElementById("tourNextButton");
    const counter = document.getElementById("tourSlideCounter");

    if (!slides.length || !prevButton || !nextButton || !counter) return;

    let index = 0;
    let timer = null;

    function render() {
        slides.forEach(function (slide, i) {
            slide.hidden = i !== index;
        });
        counter.textContent = (index + 1) + " / " + slides.length;
    }

    function move(step) {
        index = (index + step + slides.length) % slides.length;
        render();
    }

    function stopAutoPlay() {
        if (timer !== null) {
            window.clearInterval(timer);
            timer = null;
        }
    }

    function startAutoPlay() {
        stopAutoPlay();
        if (slides.length <= 1) return;
        timer = window.setInterval(function () {
            move(1);
        }, 5000);
    }

    prevButton.addEventListener("click", function () {
        move(-1);
        startAutoPlay();
    });

    nextButton.addEventListener("click", function () {
        move(1);
        startAutoPlay();
    });

    root.addEventListener("mouseenter", stopAutoPlay);
    root.addEventListener("mouseleave", startAutoPlay);

    render();
    startAutoPlay();
})();
