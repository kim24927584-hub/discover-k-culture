/*
 * 홈 관광정보 비동기 로딩 + 슬라이드
 * - 서버 GET /api/tour/home 은 30분 서버 캐시를 사용합니다.
 * - 외부 관광 API 응답을 기다리는 동안에도 홈/게시판이 먼저 나타납니다.
 * - API 데이터는 textContent 로 삽입하여 외부 데이터 XSS를 방지합니다.
 * - 기존 요소 ID, CSS 클래스 및 인라인 디자인을 그대로 사용합니다.
 */
(function () {
    "use strict";

    var root = document.getElementById("tourRecommendation");
    if (!root) return;

    var slider = document.getElementById("tourSlider");
    var prevButton = document.getElementById("tourPrevButton");
    var nextButton = document.getElementById("tourNextButton");
    var counter = document.getElementById("tourSlideCounter");
    var controls = root.querySelector(".tour-slider-controls");
    if (!slider || !prevButton || !nextButton || !counter || !controls) return;

    var slides = [];
    var currentIndex = 0;
    var timer = null;
    var fallbackImage = root.getAttribute("data-fallback-image") || "";
    var apiUrl = root.getAttribute("data-api-url") || "";

    // HTML hidden 과 인라인 display:flex 간 우선순위 충돌 방지
    controls.hidden = true;
    controls.style.display = "none";

    function clear(element) {
        while (element.firstChild) element.removeChild(element.firstChild);
    }

    function message(text) {
        clear(slider);
        var table = document.createElement("table");
        table.className = "board";
        var body = document.createElement("tbody");
        var tr = document.createElement("tr");
        var td = document.createElement("td");
        td.textContent = text;
        tr.appendChild(td);
        body.appendChild(tr);
        table.appendChild(body);
        slider.appendChild(table);
        controls.hidden = true;
        controls.style.display = "none";
    }

    function shortText(text, max) {
        text = String(text || "").replace(/\s+/g, " ").trim();
        return text.length <= max ? text : text.slice(0, max) + "...";
    }

    function sourceUrl(url) {
        url = String(url || "").trim();
        // 외부 API가 제공하는 http(s) 이미지만 허용합니다.
        return /^https?:\/\//i.test(url) ? url : fallbackImage;
    }

    function makeSlide(item) {
        var slide = document.createElement("div");
        slide.className = "tour-slide";
        var table = document.createElement("table");
        table.className = "board";
        var tbody = document.createElement("tbody");
        var tr = document.createElement("tr");
        var photoCell = document.createElement("td");
        photoCell.setAttribute("width", "105");
        photoCell.setAttribute("valign", "top");
        var img = document.createElement("img");
        img.src = sourceUrl(item.imageUrl);
        img.alt = String(item.title || "관광지");
        img.width = 95;
        img.height = 80;
        img.loading = "lazy";
        var fallbackApplied = false;
        img.addEventListener("error", function () {
            if (fallbackApplied) return;
            fallbackApplied = true;
            if (fallbackImage) img.src = fallbackImage;
        });
        photoCell.appendChild(img);

        var contentCell = document.createElement("td");
        contentCell.setAttribute("valign", "top");
        var title = document.createElement("strong");
        title.textContent = shortText(item.title, 18);
        title.title = String(item.title || "");
        contentCell.appendChild(title);
        contentCell.appendChild(document.createElement("br"));
        var description = document.createElement("span");
        var text = item.description || item.address || "";
        description.textContent = shortText(text, 34);
        description.title = String(text);
        contentCell.appendChild(description);
        contentCell.appendChild(document.createElement("br"));
        var address = document.createElement("small");
        address.textContent = shortText(item.address, 24);
        address.title = String(item.address || "");
        contentCell.appendChild(address);

        tr.appendChild(photoCell);
        tr.appendChild(contentCell);
        tbody.appendChild(tr);
        table.appendChild(tbody);
        slide.appendChild(table);
        return slide;
    }

    function render() {
        for (var i = 0; i < slides.length; i++) {
            var visible = i === currentIndex;
            slides[i].hidden = !visible;
            slides[i].style.display = visible ? "" : "none";
        }
        counter.textContent = (slides.length ? currentIndex + 1 : 0) + " / " + slides.length;
    }

    function move(step) {
        if (!slides.length) return;
        currentIndex = (currentIndex + step + slides.length) % slides.length;
        render();
    }

    function stopAutoPlay() {
        if (timer !== null) {
            clearInterval(timer);
            timer = null;
        }
    }

    function startAutoPlay() {
        stopAutoPlay();
        if (slides.length > 1) timer = setInterval(function () { move(1); }, 5000);
    }

    prevButton.addEventListener("click", function () { move(-1); startAutoPlay(); });
    nextButton.addEventListener("click", function () { move(1); startAutoPlay(); });
    root.addEventListener("mouseenter", stopAutoPlay);
    root.addEventListener("mouseleave", startAutoPlay);

    // 관광 API 장애 시 홈의 다른 콘텐츠는 영향 없이 표시됩니다.
    if (!apiUrl || typeof window.fetch !== "function") {
        message("관광 정보를 표시할 수 없습니다.");
        return;
    }

    var timeoutId = null;
    var controller = typeof AbortController === "function" ? new AbortController() : null;
    if (controller) timeoutId = setTimeout(function () { controller.abort(); }, 45000);

    fetch(apiUrl, {
        method: "GET",
        credentials: "same-origin",
        cache: "no-store",
        signal: controller ? controller.signal : undefined
    }).then(function (response) {
        if (!response.ok) throw new Error("관광 정보 요청 오류 (HTTP " + response.status + ")");
        return response.json();
    }).then(function (result) {
        if (!result || result.success !== true || !Array.isArray(result.items) || !result.items.length) {
            throw new Error("관광 정보가 없습니다.");
        }
        clear(slider);
        slides = [];
        result.items.forEach(function (item) {
            if (!item || !item.title) return;
            var slide = makeSlide(item);
            slides.push(slide);
            slider.appendChild(slide);
        });
        if (!slides.length) throw new Error("표시할 관광 정보가 없습니다.");
        currentIndex = 0;
        controls.hidden = false;
        controls.style.display = "flex";
        render();
        startAutoPlay();
    }).catch(function (error) {
        if (window.console && console.warn) console.warn("K-Culture 관광정보 로딩 오류:", error);
        message("관광 정보를 불러오지 못했습니다.");
    }).then(function () {
        if (timeoutId !== null) clearTimeout(timeoutId);
    });
})();
