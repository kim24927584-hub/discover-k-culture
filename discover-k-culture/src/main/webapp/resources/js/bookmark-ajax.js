/* 북마크 등록/해제 AJAX - 게시글 상세 및 마이페이지/북마크 목록 공용 */
(function () {
    "use strict";

    function formFields(form) {
        var parts = [];
        var fields = form.elements;
        for (var i = 0; i < fields.length; i++) {
            var el = fields[i];
            if (!el.name || el.disabled) continue;
            var type = String(el.type || "").toLowerCase();
            if (type === "submit" || type === "button" || type === "file" || type === "reset") continue;
            if ((type === "checkbox" || type === "radio") && !el.checked) continue;
            parts.push(encodeURIComponent(el.name) + "=" + encodeURIComponent(el.value));
        }
        return parts.join("&");
    }

    function updateBookmarkCount() {
        var list = document.querySelector("#bookmarkSection [data-bookmark-list]");
        if (!list) return;
        var count = list.querySelectorAll("[data-bookmark-item]").length;
        var labels = document.querySelectorAll("[data-bookmark-count]");
        for (var i = 0; i < labels.length; i++) labels[i].textContent = String(count);
        if (count === 0 && !list.querySelector("[data-bookmark-empty]")) {
            var item = document.createElement("div");
            item.className = "board-item";
            item.setAttribute("data-bookmark-empty", "");
            var body = document.createElement("div");
            body.className = "board-body";
            var title = document.createElement("span");
            title.className = "board-title";
            title.textContent = "북마크한 게시글이 없습니다.";
            body.appendChild(title);
            item.appendChild(body);
            list.appendChild(item);
        }
    }

    function updateLegacyList() {
        var list = document.querySelector("table.board-table [data-bookmark-list]");
        if (!list) return;
        var rows = list.querySelectorAll("[data-bookmark-item]");
        for (var i = 0; i < rows.length; i++) {
            var number = rows[i].querySelector("[data-bookmark-number]");
            if (number) number.textContent = String(rows.length - i);
        }
        if (rows.length === 0 && !list.querySelector("[data-bookmark-empty]")) {
            var row = document.createElement("tr");
            row.setAttribute("data-bookmark-empty", "");
            var cell = document.createElement("td");
            cell.setAttribute("colspan", "8");
            cell.textContent = "북마크한 게시글이 없습니다.";
            row.appendChild(cell);
            list.appendChild(row);
        }
    }

    function applyResult(form, data) {
        if (form.getAttribute("data-ajax-bookmark") === "toggle") {
            form.classList.toggle("active", data.bookmarked === true);
            var button = form.querySelector('button[type="submit"]');
            if (button) {
                button.setAttribute("aria-pressed", data.bookmarked ? "true" : "false");
                button.setAttribute("aria-label", data.bookmarked ? "북마크 해제" : "북마크 추가");
            }
        } else if (form.getAttribute("data-ajax-bookmark") === "remove" && data.bookmarked === false) {
            var item = form.closest("[data-bookmark-item]");
            if (item && item.parentNode) item.parentNode.removeChild(item);
            updateBookmarkCount();
            updateLegacyList();
        }
    }

    function showError(error) {
        if (window.console && console.error) console.error("북마크 AJAX 오류:", error);
        window.alert(error.message || "북마크 처리 중 오류가 발생했습니다.");
    }

    document.addEventListener("submit", function (event) {
        var form = event.target;
        if (!form || form.tagName !== "FORM" || !form.hasAttribute("data-ajax-bookmark")) return;
        event.preventDefault();
        if (form.getAttribute("data-bookmark-pending") === "true") return;

        var button = form.querySelector('button[type="submit"]');
        var body = formFields(form); // 버튼을 비활성화하기 전에 CSRF 포함해 직렬화
        form.setAttribute("data-bookmark-pending", "true");
        form.setAttribute("aria-busy", "true");
        if (button) button.disabled = true;

        function finish() {
            form.removeAttribute("data-bookmark-pending");
            form.removeAttribute("aria-busy");
            if (button) button.disabled = false;
        }

        var xhr = new XMLHttpRequest();
        xhr.open("POST", form.action, true);
        xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
        xhr.setRequestHeader("Accept", "application/json");
        xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8");
        xhr.timeout = 15000;
        xhr.onload = function () {
            try {
                var type = xhr.getResponseHeader("Content-Type") || "";
                var data = null;
                if (type.toLowerCase().indexOf("application/json") !== -1) {
                    data = JSON.parse(xhr.responseText);
                }
                if (xhr.status === 401 || (data && data.error === "LOGIN_REQUIRED")) {
                    window.alert("로그인 후 북마크를 사용할 수 있습니다.");
                    if (form.getAttribute("data-login-url")) window.location.assign(form.getAttribute("data-login-url"));
                    return;
                }
                if (xhr.status === 403) throw new Error("요청이 거부되었습니다. 페이지를 새로고침한 뒤 다시 시도해 주세요. (CSRF 확인)");
                if (xhr.status < 200 || xhr.status >= 300) throw new Error("북마크 처리 실패 (HTTP " + xhr.status + ")");
                if (!data || data.success !== true || typeof data.bookmarked !== "boolean") {
                    throw new Error("북마크 처리 응답이 올바르지 않습니다. 서버 JSP가 최신 버전인지 확인해 주세요.");
                }
                applyResult(form, data);
            } catch (e) {
                showError(e);
            } finally {
                finish();
            }
        };
        xhr.onerror = function () { finish(); showError(new Error("네트워크 연결을 확인해 주세요.")); };
        xhr.ontimeout = function () { finish(); showError(new Error("북마크 응답 시간이 초과되었습니다.")); };
        xhr.onabort = finish;
        try { xhr.send(body); } catch (e) { finish(); showError(e); }
    }, false);
})();
