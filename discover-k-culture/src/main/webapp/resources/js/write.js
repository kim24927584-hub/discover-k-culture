(function () {
    "use strict";

    function initWritePage() {
        var boardType = document.querySelector("[data-write-board-select]");
        var categoryId = document.querySelector("[data-write-category-select]");
        var cancelButton = document.getElementById("cancelButton");
        var form = document.querySelector("form.write-form");

        if (!boardType || !categoryId || !form) {
            return;
        }

        function currentType() {
            return String(boardType.value || "").trim().toUpperCase();
        }

        function syncCategoryState() {
            var isKCulture = currentType() === "KCULTURE";

            categoryId.disabled = !isKCulture;
            categoryId.required = isKCulture;

            if (isKCulture) {
                categoryId.removeAttribute("disabled");
                categoryId.setAttribute("required", "required");
                categoryId.setAttribute("aria-disabled", "false");
            } else {
                categoryId.value = "";
                categoryId.setAttribute("disabled", "disabled");
                categoryId.removeAttribute("required");
                categoryId.setAttribute("aria-disabled", "true");
            }
        }

        function syncFormAction() {
            var type = currentType();
            var postAction = form.dataset.postAction || form.action;
            var noticeAction = form.dataset.noticeAction || form.action;
            form.action = type === "NOTICE" ? noticeAction : postAction;
        }

        function syncAll() {
            syncCategoryState();
            syncFormAction();
        }

        boardType.addEventListener("change", syncAll);
        boardType.addEventListener("input", syncAll);
        window.addEventListener("pageshow", syncAll);
        syncAll();

        form.addEventListener("submit", function (event) {
            syncAll();

            if (currentType() === "KCULTURE" && !categoryId.value) {
                event.preventDefault();
                categoryId.focus();
                alert("K-컬처 탐색 게시판은 카테고리를 선택해 주세요.");
            }
        });

        if (cancelButton) {
            cancelButton.addEventListener("click", function () {
                var contextPath = document.body ? (document.body.dataset.contextPath || "") : "";
                var value = currentType();

                if (value === "QUESTION") {
                    window.location.href = contextPath + "/board/qnaList.jsp";
                } else if (value === "NOTICE") {
                    window.location.href = contextPath + "/board/noticeList.jsp";
                } else {
                    window.location.href = contextPath + "/board/category.jsp";
                }
            });
        }
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", initWritePage, { once: true });
    } else {
        initWritePage();
    }
})();
