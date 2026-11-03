(function () {
    "use strict";

    var LANGUAGE_HTML = {
        ko: "ko",
        ja: "ja",
        zh: "zh-CN",
        en: "en-US"
    };

    var MAX_BATCH_ITEMS = 20;
    var MAX_BATCH_CHARS = 24000;
    var CACHE_KEY_PREFIX = "kculture.deepl.cache.v1.";
    var CACHE_MAX_ENTRIES = 220;
    var CACHE_MAX_TEXT_LENGTH = 1200;

    var BLOCKED_TAGS = [
        "SCRIPT",
        "STYLE",
        "NOSCRIPT",
        "CODE",
        "PRE",
        "SVG",
        "PATH",
        "INPUT",
        "TEXTAREA"
    ];

    var IGNORE_SELECTOR = [
        "[data-deepl-ignore]",
        ".site-language",
        ".site-logo",
        ".footer-logo",
        ".member-profile",
        ".member-table tbody",
        ".top-card-author",
        ".member-login-id",
        ".member-nickname",
        ".member-id",
        ".social-icon-wrap"
    ].join(",");

    var BRAND_PATTERN =
        /^(K-culture|K-POP|K-FOOD|K-DRAMA|K-BEAUTY|TRAVEL|CULTURE|TOUR API)$/i;

    var EMAIL_PATTERN =
        /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    var URL_PATTERN =
        /^(https?:\/\/|www\.)/i;

    var DATE_NUMBER_PATTERN =
        /^[\d\s.,:+\-/()%#]+$/;

    /*
     * Eclipse의 오래된 JavaScript Validator는
     * /\p{L}/u 같은 Unicode property escape를
     * 문법 오류로 판단할 수 있습니다.
     *
     * 아래 정규식은 한국어/일본어/중국어/영문/유럽권 문자
     * 포함 여부를 구형 문법으로 검사합니다.
     */
    var LETTER_PATTERN =
        /[A-Za-zÀ-ÖØ-öø-ÿ\u3040-\u30ff\u3400-\u9fff\uac00-\ud7a3]/;

    function boot() {
        var shell =
            document.querySelector(".site-shell[data-site-language]")
            || document.querySelector("body[data-site-language]");

        if (!shell) {
            return;
        }

        var language =
            (shell.getAttribute("data-site-language") || "ko")
                .toLowerCase();

        var contextPath =
            shell.getAttribute("data-context-path") || "";

        document.documentElement.lang =
            LANGUAGE_HTML[language] || language;

        if (language === "ko") {
            return;
        }

        var endpoint =
            contextPath + "/api/deepl/translate";

        translatePage(
            shell,
            language,
            endpoint
        );
    }

    function translatePage(
        shell,
        language,
        endpoint
    ) {
        var targets =
            collectTargets(shell);

        if (targets.length === 0) {
            return;
        }

        var cache =
            readCache(language);

        /*
         * Map 대신 일반 객체를 사용합니다.
         * 실제 원문은 group.original에 따로 보관합니다.
         */
        var grouped = {};
        var groupedOrder = [];
        var i;

        for (i = 0; i < targets.length; i++) {
            var target = targets[i];
            var groupKey =
                "k_" + encodeURIComponent(target.original);

            if (!Object.prototype.hasOwnProperty.call(
                    grouped,
                    groupKey
                )) {

                grouped[groupKey] = {
                    original: target.original,
                    targets: []
                };

                groupedOrder.push(groupKey);
            }

            grouped[groupKey].targets.push(target);
        }

        var pending = [];

        for (i = 0; i < groupedOrder.length; i++) {
            var key = groupedOrder[i];
            var group = grouped[key];
            var original = group.original;
            var cached = cache[original];

            if (typeof cached === "string") {
                applyTranslation(
                    group.targets,
                    cached
                );
            } else {
                pending.push({
                    original: original,
                    targets: group.targets
                });
            }
        }

        if (pending.length === 0) {
            return;
        }

        document.documentElement.classList.add(
            "deepl-translating"
        );

        var batches =
            makeBatches(pending);

        var chain =
            Promise.resolve();

        for (i = 0; i < batches.length; i++) {
            chain =
                addBatchToChain(
                    chain,
                    batches[i],
                    endpoint,
                    cache,
                    language
                );
        }

        chain.then(
            function () {
                document.documentElement.classList.add(
                    "deepl-translated"
                );

                document.documentElement.classList.remove(
                    "deepl-translating"
                );
            },
            function (error) {
                if (window.console
                        && typeof console.warn === "function") {

                    console.warn(
                        "[K-culture DeepL] 번역을 적용하지 못했습니다.",
                        error
                    );

                    console.warn(
                        "[K-culture DeepL] 설정 확인 주소:",
                        (shell.getAttribute("data-context-path") || "")
                            + "/api/deepl/status"
                    );
                }

                document.documentElement.classList.remove(
                    "deepl-translating"
                );
            }
        );
    }

    function addBatchToChain(
        chain,
        batch,
        endpoint,
        cache,
        language
    ) {
        return chain.then(
            function () {
                var texts = [];
                var i;

                for (i = 0; i < batch.length; i++) {
                    texts.push(
                        batch[i].original
                    );
                }

                return requestBatch(
                    endpoint,
                    texts
                ).then(
                    function (translations) {
                        if (!translations
                                || !Array.isArray(translations)
                                || translations.length !== batch.length) {

                            throw new Error(
                                "DeepL translation count mismatch"
                            );
                        }

                        var j;

                        for (j = 0; j < batch.length; j++) {
                            var item =
                                batch[j];

                            var translated =
                                translations[j];

                            applyTranslation(
                                item.targets,
                                translated
                            );

                            if (item.original.length
                                    <= CACHE_MAX_TEXT_LENGTH) {

                                cache[item.original] =
                                    translated;
                            }
                        }

                        writeCache(
                            language,
                            cache
                        );
                    }
                );
            }
        );
    }

    function collectTargets(shell) {
        var targets = [];
        var possibleRoots;

        if (hasClass(shell, "site-shell")) {
            possibleRoots = [
                shell.querySelector(".site-sidebar"),
                shell.querySelector(".site-topbar"),
                shell.querySelector(".site-content"),
                shell.querySelector(".site-footer")
            ];
        } else {
            /*
             * 로그인 / 회원가입 / 마이페이지처럼 공통 site-shell을
             * 사용하지 않는 독립 페이지는 body 전체를 번역 대상으로 사용합니다.
             * 언어 선택 UI는 data-deepl-ignore로 제외됩니다.
             */
            possibleRoots = [shell];
        }

        var i;

        for (i = 0; i < possibleRoots.length; i++) {
            var root = possibleRoots[i];

            if (!root) {
                continue;
            }

            collectTextNodes(root, targets);
            collectAttributes(root, targets);
        }

        return targets;
    }

    function collectTextNodes(
        root,
        targets
    ) {
        var walker =
            document.createTreeWalker(
                root,
                NodeFilter.SHOW_TEXT,
                {
                    acceptNode: function (node) {
                        var parent =
                            node.parentElement;

                        if (!parent
                                || shouldIgnoreElement(parent)) {

                            return NodeFilter.FILTER_REJECT;
                        }

                        var raw =
                            node.nodeValue || "";

                        var trimmed =
                            raw.replace(
                                /^\s+|\s+$/g,
                                ""
                            );

                        if (!shouldTranslate(trimmed)) {
                            return NodeFilter.FILTER_REJECT;
                        }

                        return NodeFilter.FILTER_ACCEPT;
                    }
                }
            );

        var node;

        while ((node = walker.nextNode())) {
            var raw =
                node.nodeValue || "";

            var original =
                raw.replace(
                    /^\s+|\s+$/g,
                    ""
                );

            var start =
                raw.indexOf(original);

            var prefix =
                start > 0
                    ? raw.substring(0, start)
                    : "";

            var suffixStart =
                start + original.length;

            var suffix =
                suffixStart < raw.length
                    ? raw.substring(suffixStart)
                    : "";

            targets.push({
                kind: "text",
                node: node,
                original: original,
                prefix: prefix,
                suffix: suffix
            });
        }
    }

    function collectAttributes(
        root,
        targets
    ) {
        var elements =
            root.querySelectorAll(
                "input[placeholder], textarea[placeholder], [aria-label]"
            );

        var i;

        for (i = 0; i < elements.length; i++) {
            var element =
                elements[i];

            if (shouldIgnoreElement(element)) {
                continue;
            }

            var attributes = [
                "placeholder",
                "aria-label"
            ];

            var j;

            for (j = 0; j < attributes.length; j++) {
                var attribute =
                    attributes[j];

                if (!element.hasAttribute(attribute)) {
                    continue;
                }

                var original =
                    (element.getAttribute(attribute) || "")
                        .replace(
                            /^\s+|\s+$/g,
                            ""
                        );

                if (!shouldTranslate(original)) {
                    continue;
                }

                targets.push({
                    kind: "attribute",
                    element: element,
                    attribute: attribute,
                    original: original
                });
            }
        }
    }

    function shouldIgnoreElement(element) {
        if (arrayContains(
                BLOCKED_TAGS,
                element.tagName
            )) {

            return true;
        }

        if (typeof element.closest === "function") {
            return Boolean(
                element.closest(IGNORE_SELECTOR)
            );
        }

        /*
         * 아주 오래된 브라우저용 fallback.
         * 최신 Chrome에서는 closest()가 사용됩니다.
         */
        var current = element;

        while (current
                && current.nodeType === 1) {

            if (matchesSelector(
                    current,
                    IGNORE_SELECTOR
                )) {

                return true;
            }

            current =
                current.parentElement;
        }

        return false;
    }

    function shouldTranslate(text) {
        if (!text
                || text.length < 1) {

            return false;
        }

        if (BRAND_PATTERN.test(text)
                || EMAIL_PATTERN.test(text)
                || URL_PATTERN.test(text)
                || DATE_NUMBER_PATTERN.test(text)) {

            return false;
        }

        return LETTER_PATTERN.test(text);
    }

    function makeBatches(items) {
        var batches = [];
        var current = [];
        var currentChars = 0;
        var i;

        for (i = 0; i < items.length; i++) {
            var item =
                items[i];

            var itemChars =
                item.original.length;

            if (current.length > 0
                    && (
                        current.length >= MAX_BATCH_ITEMS
                        || currentChars + itemChars
                            > MAX_BATCH_CHARS
                    )) {

                batches.push(current);

                current = [];
                currentChars = 0;
            }

            current.push(item);
            currentChars += itemChars;
        }

        if (current.length > 0) {
            batches.push(current);
        }

        return batches;
    }

    function requestBatch(
        endpoint,
        texts
    ) {
        var body =
            new URLSearchParams();

        var i;

        for (i = 0; i < texts.length; i++) {
            body.append(
                "text",
                texts[i]
            );
        }

        return fetch(
            endpoint,
            {
                method: "POST",
                headers: {
                    "Content-Type":
                        "application/x-www-form-urlencoded;charset=UTF-8",
                    "Accept":
                        "application/json"
                },
                body: body.toString(),
                credentials: "same-origin"
            }
        ).then(
            function (response) {
                return response.text().then(
                    function (responseText) {
                        var data = null;

                        try {
                            data =
                                responseText
                                    ? JSON.parse(responseText)
                                    : null;
                        } catch (ignored) {
                            data = null;
                        }

                        if (!response.ok
                                || !data
                                || data.ok !== true) {

                            var message =
                                data
                                && data.message
                                    ? data.message
                                    : "HTTP "
                                        + response.status;

                            throw new Error(message);
                        }

                        return data.translations;
                    }
                );
            }
        );
    }

    function applyTranslation(
        targets,
        translated
    ) {
        var i;

        for (i = 0; i < targets.length; i++) {
            var target = targets[i];

            if (target.kind === "text") {
                target.node.nodeValue =
                    target.prefix
                    + translated
                    + target.suffix;

                markTranslatedUi(
                    target.node.parentElement,
                    target.original,
                    translated
                );

            } else if (
                target.kind === "attribute"
            ) {

                target.element.setAttribute(
                    target.attribute,
                    translated
                );
            }
        }
    }

    function markTranslatedUi(
        element,
        original,
        translated
    ) {
        if (!element) {
            return;
        }

        var fitElement = findFitElement(element);

        if (!fitElement) {
            return;
        }

        fitElement.classList.add("deepl-fit-text");

        var translatedLength = translated ? translated.length : 0;
        var originalLength = original ? original.length : 1;
        var ratio = translatedLength / originalLength;

        if (translatedLength >= 14 || ratio >= 1.65) {
            fitElement.classList.add("deepl-long-text");
        }

        if (translatedLength >= 24 || ratio >= 2.35) {
            fitElement.classList.add("deepl-very-long-text");
        }

        if (!fitElement.getAttribute("title")
                && translatedLength >= 14) {
            fitElement.setAttribute("title", translated);
        }

        window.setTimeout(
            function () {
                if (fitElement.scrollWidth > fitElement.clientWidth + 2) {
                    fitElement.classList.add("deepl-overflow-text");

                    if (!fitElement.getAttribute("title")) {
                        fitElement.setAttribute("title", translated);
                    }
                }
            },
            0
        );
    }

    function findFitElement(element) {
        var selector = [
            ".site-menu a",
            ".site-account a",
            ".site-admin-link",
            ".site-topbar button",
            ".site-topbar a",
            ".login-submit",
            ".join-submit",
            ".social-btn",
            ".login-links a",
            ".login-join-link a",
            ".join-login-link a",
            ".post-tab-button",
            ".post-page-btn",
            ".pagination a",
            ".pagination span",
            ".compact-btn",
            ".btn",
            "button"
        ].join(",");

        if (matchesSelector(element, selector)) {
            return element;
        }

        if (typeof element.closest === "function") {
            return element.closest(selector);
        }

        var current = element.parentElement;

        while (current && current.nodeType === 1) {
            if (matchesSelector(current, selector)) {
                return current;
            }
            current = current.parentElement;
        }

        return null;
    }

    function hasClass(element, className) {
        if (!element || !element.className) {
            return false;
        }

        if (element.classList) {
            return element.classList.contains(className);
        }

        return (" " + element.className + " ")
            .indexOf(" " + className + " ") >= 0;
    }

    function readCache(language) {
        try {
            var raw =
                sessionStorage.getItem(
                    CACHE_KEY_PREFIX
                    + language
                );

            var parsed =
                raw
                    ? JSON.parse(raw)
                    : {};

            return parsed
                && typeof parsed === "object"
                    ? parsed
                    : {};

        } catch (error) {
            return {};
        }
    }

    function writeCache(
        language,
        cache
    ) {
        try {
            var keys =
                Object.keys(cache);

            if (keys.length > CACHE_MAX_ENTRIES) {
                var trimmed = {};
                var startIndex =
                    keys.length - CACHE_MAX_ENTRIES;
                var i;

                for (
                    i = startIndex;
                    i < keys.length;
                    i++
                ) {
                    var key =
                        keys[i];

                    trimmed[key] =
                        cache[key];
                }

                cache =
                    trimmed;
            }

            sessionStorage.setItem(
                CACHE_KEY_PREFIX
                    + language,
                JSON.stringify(cache)
            );

        } catch (error) {
            /*
             * 브라우저 저장소가 막혀 있어도
             * 번역 자체는 계속 동작합니다.
             */
        }
    }

    function arrayContains(
        array,
        value
    ) {
        var i;

        for (i = 0; i < array.length; i++) {
            if (array[i] === value) {
                return true;
            }
        }

        return false;
    }

    function matchesSelector(
        element,
        selector
    ) {
        var matcher =
            element.matches
            || element.msMatchesSelector
            || element.webkitMatchesSelector;

        if (!matcher) {
            return false;
        }

        return matcher.call(
            element,
            selector
        );
    }

    if (document.readyState === "loading") {
        document.addEventListener(
            "DOMContentLoaded",
            boot
        );
    } else {
        boot();
    }
})();
