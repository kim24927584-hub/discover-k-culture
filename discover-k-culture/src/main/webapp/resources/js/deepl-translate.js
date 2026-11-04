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
    var CACHE_KEY_PREFIX = "kculture.deepl.cache.v2.";
    var CACHE_MAX_ENTRIES = 220;
    var CACHE_MAX_TEXT_LENGTH = 1200;

    /*
     * 화면의 안내 문구와 일반 게시글은 번역하되,
     * 개인 식별 정보·서비스 식별자·사용자 입력 영역은 API에 보내지 않습니다.
     * 새 HTML/JSP 요소도 data-deepl-ignore 또는 translate="no"로
     * 별도의 JavaScript 수정 없이 보호할 수 있습니다.
     */
    var BLOCKED_TAGS = [
        "SCRIPT", "STYLE", "NOSCRIPT", "CODE", "PRE",
        "KBD", "SAMP", "VAR", "SVG", "MATH",
        "IFRAME", "OBJECT", "TEMPLATE", "INPUT", "TEXTAREA"
    ];

    var IGNORE_SELECTOR = [
        "[data-deepl-ignore]",
        "[data-private-content]",
        "[translate='no']",
        ".notranslate",
        "[contenteditable]",
        "[aria-hidden='true']",
        ".site-language",
        ".site-logo",
        ".footer-logo",
        ".logo",
        ".login-user",          // 헤더 프로필 닉네임
        ".member-profile",
        ".member-table tbody",  // 관리자 회원 식별 정보 및 정지 사유
        ".top-card-author",
        ".member-login-id",
        ".member-login",
        ".member-nickname",
        ".member-id",
        ".post-writer",
        ".post-author",
        ".comment-author",
        ".col-author",
        ".social-icon-wrap",
        "#translationStatus"
    ].join(",");

    var BRAND_PATTERN =
        /^(?:K[- ]?culture|K-POP|K-FOOD|K-DRAMA|K-BEAUTY|TRAVEL|CULTURE|TOUR API|DeepL|Google|Kakao|Naver|GitHub)$/i;

    var EMAIL_PATTERN =
        /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    var URL_PATTERN =
        /^(?:https?:\/\/|www\.|mailto:|tel:|\/[^\s]*\/)/i;

    /* 순수한 숫자, 날짜, 시간, 조회수 수치 등은 번역할 이유가 없습니다. */
    var DATE_NUMBER_PATTERN =
        /^[\d\s.,:+\-/()%#]+$/;

    /* 파일명, 계정 핸들, API 오류코드, 기술적 식별자를 보존합니다. */
    var IDENTIFIER_PATTERN =
        /^(?:@[\w.-]+|[\w.-]+\.(?:jpg|jpeg|png|gif|webp|mp4|webm|pdf|jsp|java|js|css|json|xml|sql|properties)|[a-z0-9]+_[a-z0-9_.-]+|KOE\d{3,}|ERR_[A-Z0-9_]+|[A-F0-9]{16,})$/i;

    /* 이메일/전화번호/URL이 문장 안에 있어도 외부 번역 서버로 보내지 않습니다. */
    var SENSITIVE_TEXT_PATTERN =
        /(?:[^\s@]+@[^\s@]+\.[^\s@]+|https?:\/\/\S+|www\.\S+|01[016789][-\s]?\d{3,4}[-\s]?\d{4}|[A-Fa-f0-9]{8}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{12})/;

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

    /*
     * 번역 선택창 옆에는 진행/완료 문구를 표시하지 않습니다.
     * 실패 시에만 이유를 보여 사용자가 API 설정 문제를 확인할 수 있게 합니다.
     * 번역 동작 및 요청은 변경하지 않습니다.
     */
    function setTranslationStatus(message, isError) {
        var element = document.getElementById("translationStatus");
        if (!element) return;

        var showError = Boolean(isError && message);
        element.textContent = showError ? message : "";
        element.style.display = showError ? "block" : "none";
        element.style.color = "#b42318";
    }

    /*
     * 언어 변경은 CSRF 토큰을 포함한 POST 요청으로 세션에 저장합니다.
     * 일반 form.submit()과 달리, 실패하면 현재 화면에서 오류를 안내합니다.
     * 서버가 저장에 성공한 경우에만 화면을 다시 읽어 번역을 시작합니다.
     */
    function bindLanguageSelector() {
        var select = document.getElementById("siteLanguageSelect");
        if (!select || !select.form) return;

        var form = select.form;
        var previousLanguage = select.value;
        var pending = false;

        select.addEventListener("change", function () {
            if (pending) return;

            var nextLanguage = select.value;
            if (nextLanguage === previousLanguage) return;

            if (typeof window.fetch !== "function"
                    || typeof window.FormData !== "function"
                    || typeof window.URLSearchParams !== "function") {
                form.submit(); // 구형 브라우저에서는 기존 POST 방식 유지
                return;
            }

            // FormData는 disabled 필드를 제외하므로 잠그기 전에 값을 수집해야 합니다.
            var body = new URLSearchParams(new FormData(form));

            pending = true;
            select.disabled = true;
            setTranslationStatus("언어 설정 중...");

            fetch(form.action, {
                method: "POST",
                credentials: "same-origin",
                headers: {
                    "X-Requested-With": "XMLHttpRequest",
                    "Accept": "application/json",
                    "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
                },
                body: body.toString()
            }).then(function (response) {
                if (!response.ok) {
                    throw new Error(response.status === 403
                        ? "언어 변경이 거부되었습니다. 새로고침 후 다시 시도하세요."
                        : "언어 설정 실패 (HTTP " + response.status + ")");
                }
                return response.json();
            }).then(function (result) {
                if (!result || result.ok !== true || result.language !== nextLanguage) {
                    throw new Error("서버의 언어 설정 응답이 올바르지 않습니다.");
                }
                window.location.reload();
            }).catch(function (error) {
                pending = false;
                select.disabled = false;
                select.value = previousLanguage;
                setTranslationStatus(error.message || "언어 설정에 실패했습니다.", true);
                if (window.console) console.warn("[K-culture 번역] 언어 변경 실패", error);
            });
        });
    }

    function boot() {
        bindLanguageSelector();
        /*
         * 이전 버전은 1:1 문의나 회원 정보를 캐시에 담았을 수 있습니다.
         * 새 보호 규칙을 적용하기 전에 구버전 세션 캐시를 정리합니다.
         */
        try {
            var legacyLanguages = ["ko", "ja", "zh", "en"];
            var legacyIndex;
            for (legacyIndex = 0; legacyIndex < legacyLanguages.length; legacyIndex++) {
                sessionStorage.removeItem("kculture.deepl.cache.v1." + legacyLanguages[legacyIndex]);
            }
        } catch (ignored) {
            // 세션 저장소 차단 상태라도 번역 기능은 계속 사용합니다.
        }

        // 공통 헤더는 body에 data-site-language를 설정합니다.
        // 내부의 임의 wrapper가 선택되더라도 문서 전체 텍스트를 수집하도록 body를 우선합니다.
        var shell =
            document.querySelector("body[data-site-language]")
            || document.querySelector(".site-shell[data-site-language]");

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
            setTranslationStatus("");
            return;
        }
        setTranslationStatus("번역 중...");

        var endpoint =
            contextPath + "/api/deepl/translate";

        try {
            translatePage(shell, language, endpoint);
        } catch (error) {
            setTranslationStatus("번역 초기화 오류 · F12 콘솔 확인", true);
            if (window.console) console.error("[K-culture 번역] 초기화 실패", error);
        }
    }

    function translatePage(
        shell,
        language,
        endpoint
    ) {
        var targets =
            collectTargets(shell);

        if (targets.length === 0) {
            setTranslationStatus("번역할 내용 없음");
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
            setTranslationStatus("번역 완료");
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
                setTranslationStatus("번역 완료");
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

                var statusMessage = "번역 실패 · DeepL 설정 확인";
                if (error && error.apiCode === "DEEPL_NOT_CONFIGURED") {
                    statusMessage = "DeepL API 키가 설정되지 않았습니다.";
                } else if (error && error.httpStatus === 429) {
                    statusMessage = "번역 사용량 제한 · 잠시 후 재시도";
                } else if (error && error.httpStatus === 403) {
                    statusMessage = "번역 요청 거부 · API 키 확인";
                }
                setTranslationStatus(statusMessage, true);
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
        /*
         * 텍스트의 직접 부모가 span이라도 상위에 code/pre/textarea 등이
         * 있으면 번역하지 않아야 합니다. 기존 코드는 부모 태그만 검사해서
         * <code><span>...</span></code> 내부가 번역될 가능성이 있었습니다.
         */
        var current = element;

        while (current && current.nodeType === 1) {
            if (arrayContains(BLOCKED_TAGS, current.tagName)
                    || matchesSelector(current, IGNORE_SELECTOR)) {
                return true;
            }

            current = current.parentElement;
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
                || DATE_NUMBER_PATTERN.test(text)
                || IDENTIFIER_PATTERN.test(text)
                || SENSITIVE_TEXT_PATTERN.test(text)) {

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

                            var problem = new Error(message);
                            problem.apiCode = data && data.code ? data.code : "";
                            problem.httpStatus = response.status;
                            throw problem;
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
