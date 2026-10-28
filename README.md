```
src/main/webapp/
├── index.jsp
├── include/                 ← 모든 페이지가 공유 (헤더 담당 팀원)
│   ├── header.jsp
│   ├── footer.jsp
│   ├── sidebar-left.jsp
│   └── sidebar-right.jsp
├── member/
│   ├── login.jsp            ← 화면
│   ├── loginProc.jsp        ← 처리 (화면 없음, 이동만)
│   ├── join.jsp
│   └── joinProc.jsp
├── board/
│   ├── list.jsp
│   ├── view.jsp
│   ├── write.jsp
│   └── writeProc.jsp
├── admin/
│   └── index.jsp
├── resources/               ← CSS, JS, 이미지
│   ├── css/  (common.css, header.css, board.css ...)
│   ├── js/
│   └── img/
└── WEB-INF/
    └── web.xml
```
