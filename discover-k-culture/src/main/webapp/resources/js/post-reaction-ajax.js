/*
 * 게시글 / 댓글 추천·비추천 AJAX 처리 (Eclipse 호환 문법 버전)
 *
 * - async/await, fetch, URLSearchParams 등의 최신 문법/객체를 사용하지 않습니다.
 * - 기존 JSP POST 폼과 서버의 JSON 응답 형식은 그대로 사용합니다.
 * - 추천·비추천 수 및 선택 버튼만 갱신하고 전체 페이지를 새로고침하지 않습니다.
 * - _csrf 필드를 포함하여 전송하고 응답 전 중복 클릭을 막습니다.
 * - CSS 및 HTML 구조는 변경하지 않습니다.
 */
(function () {
    "use strict";

    // 좋아요/싫어요 각각의 POST 폼 찾기
    function reactionForm(group, action) {
        return group.querySelector('form[data-reaction="' + action + '"]');
    }

    // 서버가 반환한 실제 선택 상태와 숫자로 버튼 갱신
    function updateReaction(group, action, active, count) {
        var form = reactionForm(group, action);
        if (!form) return;

        var button = form.querySelector('button[type="submit"]');
        if (!button) return;

        if (active) {
            button.classList.add("active");
        } else {
            button.classList.remove("active");
        }
        button.setAttribute("aria-pressed", active ? "true" : "false");

        var counter = button.querySelector('[data-reaction-count="' + action + '"]');
        if (counter && count !== null && typeof count !== "undefined") {
            counter.textContent = String(count);
        }
    }

    // 게시글 메타 정보 + 게시글/댓글 버튼 숫자 갱신
    function renderResult(group, result) {
        updateReaction(group, "like", result.liked, result.likeCount);
        updateReaction(group, "dislike", result.disliked, result.dislikeCount);

        if (group.getAttribute("data-reaction-group") === "post") {
            var likeMeta = document.querySelector('[data-post-meta-reaction="like"]');
            var dislikeMeta = document.querySelector('[data-post-meta-reaction="dislike"]');
            if (likeMeta) likeMeta.textContent = String(result.likeCount);
            if (dislikeMeta) dislikeMeta.textContent = String(result.dislikeCount);
        }
    }

    // POST 폼의 필드를 x-www-form-urlencoded 형식으로 변환합니다.
    // 기존 header.jsp가 자동 추가한 _csrf도 함께 전송됩니다.
    function serializeForm(form) {
        var params = [];
        var elements = form.elements;
        var i, field, type;

        for (i = 0; i < elements.length; i++) {
            field = elements[i];
            if (!field.name || field.disabled) continue;

            type = String(field.type || "").toLowerCase();
            if (type === "submit" || type === "button" || type === "reset" || type === "file") continue;
            if ((type === "checkbox" || type === "radio") && !field.checked) continue;

            params.push(encodeURIComponent(field.name) + "=" + encodeURIComponent(field.value));
        }
        return params.join("&");
    }

    // 요청 중 그룹에 포함된 추천·비추천 버튼 잠금 / 잠금 해제
    function setBusy(group, buttons, busy) {
        var i;
        if (busy) {
            group.setAttribute("data-reaction-pending", "true");
            group.setAttribute("aria-busy", "true");
        } else {
            group.removeAttribute("data-reaction-pending");
            group.removeAttribute("aria-busy");
        }
        for (i = 0; i < buttons.length; i++) {
            buttons[i].disabled = busy;
        }
    }

    function showError(message, error) {
        if (window.console && window.console.error) {
            window.console.error("추천/비추천 AJAX 오류:", error || message);
        }
        window.alert(message);
    }

    // 서버가 내려준 JSON 응답을 읽고 상태 갱신
    function processResponse(xhr, group, form) {
        var result = null;
        var contentType = xhr.getResponseHeader("Content-Type") || "";
        var errorMessage;

        if (contentType.toLowerCase().indexOf("application/json") !== -1) {
            try {
                result = JSON.parse(xhr.responseText);
            } catch (e) {
                throw new Error("서버 JSON 응답을 읽을 수 없습니다.");
            }
        }

        if (xhr.status === 401 || (result && result.error === "LOGIN_REQUIRED")) {
            window.alert("로그인이 필요합니다. 로그인 화면으로 이동합니다.");
            window.location.assign(form.action.split("/board/process/")[0] + "/member/login.jsp");
            return;
        }

        if (xhr.status === 403 && result && result.error === "SUSPENDED") {
            throw new Error("정지된 계정에서는 추천/비추천을 사용할 수 없습니다.");
        }

        if (xhr.status === 403) {
            throw new Error("요청이 거부되었습니다. 페이지를 새로고침한 뒤 다시 시도해 주세요. (CSRF 확인)");
        }

        if (xhr.status < 200 || xhr.status >= 300) {
            throw new Error("추천/비추천 처리에 실패했습니다. (HTTP " + xhr.status + ")");
        }

        if (!result) {
            errorMessage = "서버에서 JSON이 아닌 응답을 받았습니다. likeProcess.jsp / dislikeProcess.jsp를 확인해 주세요.";
            throw new Error(errorMessage);
        }

        if (result.success !== true) {
            throw new Error("추천/비추천 처리를 완료하지 못했습니다. (" + (result.error || "UNKNOWN") + ")");
        }

        renderResult(group, result);
    }

    // form 제출을 가로채 XMLHttpRequest로 비동기 POST 전송
    function handleSubmit(event) {
        var form = event.target;
        var group, buttons, body, xhr, finished;

        if (!form || String(form.tagName).toUpperCase() !== "FORM") return;
        if (form.getAttribute("data-ajax-reaction") === null) return;

        event.preventDefault();  // 전체 페이지 새로고침 차단

        group = form.closest("[data-reaction-group]");
        if (!group || group.getAttribute("data-reaction-pending") === "true") return;

        // 비활성화 전에 body를 생성하여 hidden 값과 CSRF 필드가 빠지지 않게 합니다.
        body = serializeForm(form);
        buttons = group.querySelectorAll('form[data-ajax-reaction] button[type="submit"]');
        setBusy(group, buttons, true);
        finished = false;

        function finish() {
            if (finished) return;
            finished = true;
            setBusy(group, buttons, false);
        }

        try {
            xhr = new XMLHttpRequest();
            xhr.open("POST", form.action, true);
            xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
            xhr.setRequestHeader("Accept", "application/json");
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8");
            xhr.timeout = 15000;

            xhr.onload = function () {
                try {
                    processResponse(xhr, group, form);
                } catch (error) {
                    showError(error.message || "서버 처리 오류", error);
                } finally {
                    finish();
                }
            };

            xhr.onerror = function () {
                showError("서버에 연결할 수 없습니다. 네트워크를 확인해 주세요.");
                finish();
            };

            xhr.ontimeout = function () {
                showError("요청 시간이 초과되었습니다. 다시 시도해 주세요.");
                finish();
            };

            xhr.onabort = finish;
            xhr.send(body);
        } catch (error) {
            finish();
            showError(error.message || "추천/비추천 요청을 시작할 수 없습니다.", error);
        }
    }

    // 동적으로 생성된 댓글 폼에도 한 번의 이벤트 등록으로 적용
    document.addEventListener("submit", handleSubmit, false);
})();
