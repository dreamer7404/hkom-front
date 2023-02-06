G_DEPlugin["mention"].config = {
    /** allowMentionRegExp
     * 멘션허용 패턴 설정 입니다.(정규식) 
     * 사용자가 @ 문자 뒤에 텍스트 입력 시 아래 조건에 부합되지 않으면 멘션이 취소 됩니다.
     * 아래 조건은 영문(대소문자), 숫자, 한글 입력을 허용하는 설정 입니다.
     **/
    allowMentionRegExp: 'a-z|A-Z|0-9|ㄱ-ㅎ|가-힣',

    /** appliedMentionCss
     * 완성된 멘션 항목을 꾸미기 위한 css 파일 입니다. 에디터 작성영역에 해당 css가 추가 됩니다.
     * "http" 또는 "/" 로 시작하는 url을 넣는 경우 해당 url로 추가 되고
       파일명만 넣는 경우 에디터폴더/plugin/mention/css/ 폴더 안에 있는 해당 파일이 추가 됩니다.
     **/
    appliedMentionCss: 'mention.css',

    /** appliedMentionClass
     * 완성된 멘션 항목의 class명 입니다.
     * 멘션이 만들어 지면 아래 클래스가 추가 됩니다.
     * 위 appliedMentionCss으로 설정한 css에서 아래 class 명으로 style을 적용하시면 됩니다.
     **/
    appliedMentionClass: 'DE_Mention',

    /** listUI
     * @뒤에 문자 입력 시 활성화 되는 멘션 리스트 UI 설정 입니다.
     **/
    listUI: {
        /** width
         * UI의 가로 크기 입니다.
         **/
        width: '120px',

        /** css
         * 리스트 UI에서 사용할 css 입니다.
         * "http" 또는 "/" 로 시작하는 url을 넣는 경우 해당 url로 추가 되고
           파일명만 넣는 경우 에디터폴더/plugin/mention/css/ 폴더 안에 있는 해당 파일이 추가 됩니다.
         **/
        css: ['mentionList.css'],

        /** selectedClass
         * 리스트 UI에서 멘션이 선택되어 있음을 나타내 주는 class 명 입니다.
         * 위 css 파일에서 아래 클래스명에 대한 style을 적용해 주시면 됩니다.
         **/
        selectedClass: ['mListSelected'],

        /** mentionList
         * 멘션 리스트에서 보여줄 리스트 입니다.
         * 리스트 하나 당 { displayName: '홍길동', attributes: { 'attrtibuteName': 'attrtibuteValue' } } 형태로 추가 해 주시면 됩니다.
           displayName은 화면에 보여줄 이름 입니다.
           attributes는 멘션 삽입 시 해당 태그에 부여할 속성명, 속성 이름 입니다.
           예) { displayName: '홍길동', attributes: { 'emp_id': 'id1' } } 형태로 추가되었다면 멘션이 추가되었을 때 아래와 같이 태그가 만들어 집니다.
               <span ...생략 emp_id="id1">@홍길동</span>
         **/
        mentionList: null
    },

    /** event
     * 멘션 기능 커스터 마이징을 위한 이벤트 함수들 입니다.
     * onLoadedMentionPlugin: 멘션 기능 로드 완료 시 호출되는 함수 입니다.
                              설정하지 않으면 dext_editor_loaded_mention_plugin_event 함수가 호출 됩니다.
     * onEnableMentionEvent: @뒤에 문자 입력 시 멘션이 활성화 되면 호출되는 함수 입니다.
                             설정하지 않으면 dext_editor_enable_mention_event 함수가 호출 됩니다.
     * onClickedMentionListEvent: mention 리스트 UI에서 리스트 선택 시 발생되는 함수 입니다.
                                  설정하지 않으면 dext_editor_clicked_mention_event 함수가 호출 됩니다.
     * onBeforeCreateMentionList: mention 리스트에서 각 사용자별 멘션이 만들어 지기 전에 발생하는 함수 입니다.
                                  설정하지 않으면 dext_editor_before_create_mention_list_event 함수가 호출 됩니다.
     **/
    event: {
        onLoadedMentionPlugin: null,
        onEnableMentionEvent: null,
        onClickedMentionListEvent: null,
        onBeforeCreateMentionList: null
    }
};