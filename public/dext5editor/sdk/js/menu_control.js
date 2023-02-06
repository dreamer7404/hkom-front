var G_vertical = '\u000B';
var G_formfeed = '\u000C';

var strSelectedMenu = '0,0';
var strMenuStatus = '';

//1 : icon (1 : intro, 2 : guide, 3 : sample, 4 : setting, 5 : brace, 6 : serverinfo, 7 : js, 8 : net, 9 : java)
//2 : title flag (0 : false, 1 : true)
//3 : title
//4 : url

var arrFirstMenu = ['1' + G_vertical + '0' + G_vertical + '소개', '2' + G_vertical + '0' + G_vertical + '클라이언트 가이드', '3' + G_vertical + '0' + G_vertical + '샘플'];
var arrSecondMenu = [
    ['4' + G_vertical + '1' + G_vertical + '설치 및 기본설정' + G_vertical + 'html/dext5editorSdkMain.html'],
    ['4' + G_vertical + '0' + G_vertical + 'Settings',
     '5' + G_vertical + '0' + G_vertical + 'Methods',
     '5' + G_vertical + '0' + G_vertical + 'Events'],
    ['3' + G_vertical + '1' + G_vertical + '기본 에디터 생성' + G_vertical + 'sample/html/sample_editor.html',
     '3' + G_vertical + '1' + G_vertical + '동적 에디터 생성' + G_vertical + 'sample/html/sample_ajax.html',
     '3' + G_vertical + '1' + G_vertical + '다중 에디터' + G_vertical + 'sample/html/sample_multi_editor.html',
     '3' + G_vertical + '1' + G_vertical + '특정위치에 내용삽입' + G_vertical + 'sample/html/sample_insert_editor.html',
     '3' + G_vertical + '1' + G_vertical + 'Css Url 추가' + G_vertical + 'sample/html/sample_cssurl_editor.html',
     '3' + G_vertical + '1' + G_vertical + 'Html Url 불러오기' + G_vertical + 'sample/html/sample_loadhtml_editor.html',
     '3' + G_vertical + '1' + G_vertical + 'UI 컨트롤' + G_vertical + 'sample/html/sample_toolbar_editor.html',
     '3' + G_vertical + '1' + G_vertical + '포커스 제어' + G_vertical + 'sample/html/sample_cursor_editor.html',
     '3' + G_vertical + '1' + G_vertical + '사용자 이미지 처리' + G_vertical + 'sample/html/sample_upload_editor.html',
     '3' + G_vertical + '1' + G_vertical + '에디터 객체 컨트롤' + G_vertical + 'sample/html/sample_editor_dom.html',
     '3' + G_vertical + '1' + G_vertical + '웹 접근성 검증' + G_vertical + 'sample/html/sample_accessibility_validation.html',
     '3' + G_vertical + '1' + G_vertical + 'DOM 관리' + G_vertical + 'sample/html/sample_form_editor.html',
     '3' + G_vertical + '1' + G_vertical + '숨겨진 영역에서 생성' + G_vertical + 'sample/html/sample_display_none.html',
     '3' + G_vertical + '1' + G_vertical + '에디터 서명 삽입' + G_vertical + 'sample/html/sample_insert_signature.html',
     '3' + G_vertical + '1' + G_vertical + '해상도별 보기 페이지' + G_vertical + 'sample/html/sample_editor_view.html']
];
var arrThirdMenu = [
    [],
    [
        ['7' + G_vertical + '1' + G_vertical + 'InitXml' + G_vertical + 'html/client/_s_InitXml.html',
         '7' + G_vertical + '1' + G_vertical + 'InitServerXml' + G_vertical + 'html/client/_s_InitServerXml.html',
         '7' + G_vertical + '1' + G_vertical + 'InitVisible' + G_vertical + 'html/client/_s_InitVisible.html',
         '7' + G_vertical + '1' + G_vertical + 'EditorHolder' + G_vertical + 'html/client/_s_EditorHolder.html',
         '7' + G_vertical + '1' + G_vertical + 'IgnoreSameEditorName' + G_vertical + 'html/client/_s_IgnoreSameEditorName.html',
         '7' + G_vertical + '1' + G_vertical + 'DefaultMessage' + G_vertical + 'html/client/_s_DefaultMessage.html',
         '7' + G_vertical + '1' + G_vertical + 'DialogWindow' + G_vertical + 'html/client/_s_DialogWindow.html',
         '7' + G_vertical + '1' + G_vertical + 'Doctype' + G_vertical + 'html/client/_s_Doctype.html',
         '7' + G_vertical + '1' + G_vertical + 'EditorBorder' + G_vertical + 'html/client/_s_EditorBorder.html',
         '7' + G_vertical + '1' + G_vertical + 'FileFieldID' + G_vertical + 'html/client/_s_FileFieldID.html',
         '7' + G_vertical + '1' + G_vertical + 'FirstLoadMessage' + G_vertical + 'html/client/_s_FirstLoadMessage.html',
         '7' + G_vertical + '1' + G_vertical + 'FocusInitObjId' + G_vertical + 'html/client/_s_FocusInitObjId.html',
         '7' + G_vertical + '1' + G_vertical + 'FormattingList' + G_vertical + 'html/client/_s_FormattingList.html',
         '7' + G_vertical + '1' + G_vertical + 'NextTabElementId' + G_vertical + 'html/client/_s_NextTabElementId.html',
         '7' + G_vertical + '1' + G_vertical + 'SetValueObjId' + G_vertical + 'html/client/_s_SetValueObjId.html',
         '7' + G_vertical + '1' + G_vertical + 'TabIndexObjId' + G_vertical + 'html/client/_s_TabIndexObjId.html',
         '7' + G_vertical + '1' + G_vertical + 'UserFieldID,UserFieldValue' + G_vertical + 'html/client/_s_UserFieldID,UserFieldValue.html',
         '7' + G_vertical + '1' + G_vertical + 'ZIndex' + G_vertical + 'html/client/_s_ZIndex.html',
         '7' + G_vertical + '1' + G_vertical + 'License' + G_vertical + 'html/client/_s_License.html',
         '7' + G_vertical + '1' + G_vertical + '[PL]MimeUse' + G_vertical + 'html/client/_s_MimeUse.html',
         '7' + G_vertical + '1' + G_vertical + '[PL]MimeCharset' + G_vertical + 'html/client/_s_MimeCharset.html',
         '7' + G_vertical + '1' + G_vertical + '[PL]MimeConentEncodingType' + G_vertical + 'html/client/_s_MimeConentEncodingType.html',
         '7' + G_vertical + '1' + G_vertical + '[PL]MimeFileTypeFilter' + G_vertical + 'html/client/_s_MimeFileTypeFilter.html',
         '7' + G_vertical + '1' + G_vertical + '[PL]MimeLocalOnly' + G_vertical + 'html/client/_s_MimeLocalOnly.html',
         '7' + G_vertical + '1' + G_vertical + '[PL]MimeRemoveHeader' + G_vertical + 'html/client/_s_MimeRemoveHeader.html',
         '7' + G_vertical + '1' + G_vertical + '[PL]PrintPreview' + G_vertical + 'html/client/_s_PrintPreview.html',
         '7' + G_vertical + '1' + G_vertical + '[PL]PrintHeader' + G_vertical + 'html/client/_s_PrintHeader.html',
         '7' + G_vertical + '1' + G_vertical + '[PL]PrintFooter' + G_vertical + 'html/client/_s_PrintFooter.html',
         '7' + G_vertical + '1' + G_vertical + '[PL]TrustSites' + G_vertical + 'html/client/_s_TrustSites.html',
         '7' + G_vertical + '1' + G_vertical + 'XssUse' + G_vertical + 'html/client/_s_XssUse.html',
         '7' + G_vertical + '1' + G_vertical + 'XssAllowEventsAttribute' + G_vertical + 'html/client/_s_XssAllowEventsAttribute.html',
         '7' + G_vertical + '1' + G_vertical + 'XssRemoveTags' + G_vertical + 'html/client/_s_XssRemoveTags.html',
         '7' + G_vertical + '1' + G_vertical + 'XssRemoveEvents' + G_vertical + 'html/client/_s_XssRemoveEvents.html',
         '7' + G_vertical + '1' + G_vertical + 'ForbiddenWord' + G_vertical + 'html/client/_s_ForbiddenWord.html', 
         '7' + G_vertical + '1' + G_vertical + 'TopMenu' + G_vertical + 'html/client/_s_TopMenu.html',
         '7' + G_vertical + '1' + G_vertical + 'ToolBar1' + G_vertical + 'html/client/_s_ToolBar1.html',
         '7' + G_vertical + '1' + G_vertical + 'ToolBar2' + G_vertical + 'html/client/_s_ToolBar2.html',
         '7' + G_vertical + '1' + G_vertical + 'StatusBar' + G_vertical + 'html/client/_s_StatusBar.html',
         '7' + G_vertical + '1' + G_vertical + 'StatusBarInitMode' + G_vertical + 'html/client/_s_StatusBarInitMode.html',
         '7' + G_vertical + '1' + G_vertical + 'RemoveItem' + G_vertical + 'html/client/_s_RemoveItem.html',
         '7' + G_vertical + '1' + G_vertical + 'RemoveContextItem' + G_vertical + 'html/client/_s_RemoveContextItem.html',
         '7' + G_vertical + '1' + G_vertical + 'FontSize' + G_vertical + 'html/client/_s_FontSize.html',
         '7' + G_vertical + '1' + G_vertical + 'FontFamily' + G_vertical + 'html/client/_s_FontFamily.html',
         '7' + G_vertical + '1' + G_vertical + 'UseLocalFont' + G_vertical + 'html/client/_s_UseLocalFont.html',
         '7' + G_vertical + '1' + G_vertical + 'UseRecentlyFont' + G_vertical + 'html/client/_s_UseRecentlyFont.html',
         '7' + G_vertical + '1' + G_vertical + 'LineHeight' + G_vertical + 'html/client/_s_LineHeight.html',
         '7' + G_vertical + '1' + G_vertical + 'RunTimes' + G_vertical + 'html/client/_s_RunTimes.html',
         '7' + G_vertical + '1' + G_vertical + 'Encoding' + G_vertical + 'html/client/_s_Encoding.html',
         '7' + G_vertical + '1' + G_vertical + 'IeCompatible' + G_vertical + 'html/client/_s_IeCompatible.html',
         '7' + G_vertical + '1' + G_vertical + 'Xmlnsname' + G_vertical + 'html/client/_s_Xmlnsname.html',
         '7' + G_vertical + '1' + G_vertical + 'Lang' + G_vertical + 'html/client/_s_Lang.html',
         '7' + G_vertical + '1' + G_vertical + 'Width' + G_vertical + 'html/client/_s_Width.html',
         '7' + G_vertical + '1' + G_vertical + 'Height' + G_vertical + 'html/client/_s_Height.html',
         '7' + G_vertical + '1' + G_vertical + 'SkinName' + G_vertical + 'html/client/_s_SkinName.html',
         '7' + G_vertical + '1' + G_vertical + 'DefaultFontFamily' + G_vertical + 'html/client/_s_DefaultFontFamily.html',
         '7' + G_vertical + '1' + G_vertical + 'DefaultFontSize' + G_vertical + 'html/client/_s_DefaultFontSize.html',
         '7' + G_vertical + '1' + G_vertical + 'DefaultLineHeight' + G_vertical + 'html/client/_s_DefaultLineHeight.html',
         '7' + G_vertical + '1' + G_vertical + 'ShowFontReal' + G_vertical + 'html/client/_s_ShowFontReal.html',
         '7' + G_vertical + '1' + G_vertical + 'Accessibility' + G_vertical + 'html/client/_s_Accessibility.html',
         '7' + G_vertical + '1' + G_vertical + 'ShowTopMenu' + G_vertical + 'html/client/_s_ShowTopMenu.html',
         '7' + G_vertical + '1' + G_vertical + 'ShowToolBar' + G_vertical + 'html/client/_s_ShowToolBar.html',
         '7' + G_vertical + '1' + G_vertical + 'Grouping' + G_vertical + 'html/client/_s_Grouping.html',
         '7' + G_vertical + '1' + G_vertical + 'ShowStatusBar' + G_vertical + 'html/client/_s_ShowStatusBar.html',
         '7' + G_vertical + '1' + G_vertical + 'StatusBarLoading' + G_vertical + 'html/client/_s_StatusBarLoading.html',
         '7' + G_vertical + '1' + G_vertical + 'ShowDialogPosition' + G_vertical + 'html/client/_s_ShowDialogPosition.html',
         '7' + G_vertical + '1' + G_vertical + 'SourceViewtype' + G_vertical + 'html/client/_s_SourceViewtype.html',
         '7' + G_vertical + '1' + G_vertical + 'WrapPtagToSource' + G_vertical + 'html/client/_s_WrapPtagToSource.html',
         '7' + G_vertical + '1' + G_vertical + 'UserCssUrl' + G_vertical + 'html/client/_s_UserCssUrl.html',
         '7' + G_vertical + '1' + G_vertical + 'XhtmlValue' + G_vertical + 'html/client/_s_XhtmlValue.html',
         '7' + G_vertical + '1' + G_vertical + 'ViewModeAutoWidth' + G_vertical + 'html/client/_s_ViewModeAutoWidth.html',
         '7' + G_vertical + '1' + G_vertical + 'ViewModeAutoHeight' + G_vertical + 'html/client/_s_ViewModeAutoHeight.html',
         '7' + G_vertical + '1' + G_vertical + 'SystemTitle' + G_vertical + 'html/client/_s_SystemTitle.html',
         '7' + G_vertical + '1' + G_vertical + 'TableAutoAdjust' + G_vertical + 'html/client/_s_TableAutoAdjust.html',
         // 아래에 새로 추가 '7' + G_vertical + '1' + G_vertical + 'UseRuler' + G_vertical + 'html/client/_s_UseRuler.html',
         '7' + G_vertical + '1' + G_vertical + 'AutoBodyFit' + G_vertical + 'html/client/_s_AutoBodyFit.html',
         '7' + G_vertical + '1' + G_vertical + 'ScrollOverflow' + G_vertical + 'html/client/_s_ScrollOverflow.html',
         '7' + G_vertical + '1' + G_vertical + 'UseHorizontalLine' + G_vertical + 'html/client/_s_UseHorizontalLine.html',
         '7' + G_vertical + '1' + G_vertical + 'ImageBaseUrl' + G_vertical + 'html/client/_s_ImageBaseUrl.html',
         '7' + G_vertical + '1' + G_vertical + 'ContextMenuDisable' + G_vertical + 'html/client/_s_ContextMenuDisable.html',
         '7' + G_vertical + '1' + G_vertical + 'EnterTag' + G_vertical + 'html/client/_s_EnterTag.html',
         '7' + G_vertical + '1' + G_vertical + 'FrameFullScreen' + G_vertical + 'html/client/_s_FrameFullScreen.html',
         '7' + G_vertical + '1' + G_vertical + 'ImgDefaultSize' + G_vertical + 'html/client/_s_ImgDefaultSize.html',
         '7' + G_vertical + '1' + G_vertical + 'AllowInoutdentText' + G_vertical + 'html/client/_s_AllowInoutdentText.html',
         '7' + G_vertical + '1' + G_vertical + 'TableDefaultWidth' + G_vertical + 'html/client/_s_TableDefaultWidth.html',
         '7' + G_vertical + '1' + G_vertical + 'TableDefaultHeight' + G_vertical + 'html/client/_s_TableDefaultHeight.html',
         '7' + G_vertical + '1' + G_vertical + 'TableDefaultClass' + G_vertical + 'html/client/_s_TableDefaultClass.html',
         '7' + G_vertical + '1' + G_vertical + 'TableDefaultInoutdent' + G_vertical + 'html/client/_s_TableDefaultInoutdent.html',
         '7' + G_vertical + '1' + G_vertical + 'TableInitInoutdent' + G_vertical + 'html/client/_s_TableInitInoutdent.html',
         '7' + G_vertical + '1' + G_vertical + 'TableDefaultTdHeight' + G_vertical + 'html/client/_s_TableDefaultTdHeight.html',
         '7' + G_vertical + '1' + G_vertical + 'TableRowMaxCount' + G_vertical + 'html/client/_s_TableRowMaxCount.html',
         '7' + G_vertical + '1' + G_vertical + 'TableColMaxCount' + G_vertical + 'html/client/_s_TableColMaxCount.html',
         '7' + G_vertical + '1' + G_vertical + 'AdjustCursorInTable' + G_vertical + 'html/client/_s_AdjustCursorInTable.html',
         '7' + G_vertical + '1' + G_vertical + 'TableClassList' + G_vertical + 'html/client/_s_TableClassList.html',
         '7' + G_vertical + '1' + G_vertical + 'TableLineStyleList' + G_vertical + 'html/client/_s_TableLineStyleList.html',
         '7' + G_vertical + '1' + G_vertical + 'TableNoResizeClass' + G_vertical + 'html/client/_s_TableNoResizeClass.html',
         '7' + G_vertical + '1' + G_vertical + 'TableInsertDragSize' + G_vertical + 'html/client/_s_TableInsertDragSize.html',
         '7' + G_vertical + '1' + G_vertical + 'ShowLineForBorderNone' + G_vertical + 'html/client/_s_ShowLineForBorderNone.html',
         '7' + G_vertical + '1' + G_vertical + 'UseMouseTableInoutdent' + G_vertical + 'html/client/_s_UseMouseTableInoutdent.html',
         '7' + G_vertical + '1' + G_vertical + 'SetDefaultStyle' + G_vertical + 'html/client/_s_SetDefaultStyle.html',
         '7' + G_vertical + '1' + G_vertical + '[PL]PasteToImage' + G_vertical + 'html/client/_s_PasteToImage.html',
         '7' + G_vertical + '1' + G_vertical + 'EditorTabDisable' + G_vertical + 'html/client/_s_EditorTabDisable.html',
         '7' + G_vertical + '1' + G_vertical + 'RemoveSpaceInTagname' + G_vertical + 'html/client/_s_RemoveSpaceInTagname.html',
         '7' + G_vertical + '1' + G_vertical + 'ViewModeBrowserMenu' + G_vertical + 'html/client/_s_ViewModeBrowserMenu.html',
         '7' + G_vertical + '1' + G_vertical + 'ViewModeAllowCopy' + G_vertical + 'html/client/_s_ViewModeAllowCopy.html',
         '7' + G_vertical + '1' + G_vertical + 'DragAndDropAllow' + G_vertical + 'html/client/_s_DragAndDropAllow.html',
         '7' + G_vertical + '1' + G_vertical + 'FormListUrl' + G_vertical + 'html/client/_s_FormListUrl.html',
         '7' + G_vertical + '1' + G_vertical + 'Mode' + G_vertical + 'html/client/_s_Mode.html',
         '7' + G_vertical + '1' + G_vertical + 'Resizebar' + G_vertical + 'html/client/_s_Resizebar.html',
         '7' + G_vertical + '1' + G_vertical + 'DragResize' + G_vertical + 'html/client/_s_DragResize.html',
         '7' + G_vertical + '1' + G_vertical + 'RemoveComment' + G_vertical + 'html/client/_s_RemoveComment.html',
         '7' + G_vertical + '1' + G_vertical + 'UserHelpUrl' + G_vertical + 'html/client/_s_UserHelpUrl.html',
         '7' + G_vertical + '1' + G_vertical + 'EditorBodyEditable' + G_vertical + 'html/client/_s_EditorBodyEditable.html',
         '7' + G_vertical + '1' + G_vertical + 'UseCorrectInOutdent' + G_vertical + 'html/client/_s_UseCorrectInOutdent.html',
         '7' + G_vertical + '1' + G_vertical + 'Ie11Jaso' + G_vertical + 'html/client/_s_Ie11Jaso.html',
         '7' + G_vertical + '1' + G_vertical + 'AutoDestroy' + G_vertical + 'html/client/_s_AutoDestroy.html',
         '7' + G_vertical + '1' + G_vertical + 'EncryptParam' + G_vertical + 'html/client/_s_EncryptParam.html',
         '7' + G_vertical + '1' + G_vertical + 'UseHtml5mode' + G_vertical + 'html/client/_s_UseHtml5mode.html',
         '7' + G_vertical + '1' + G_vertical + 'DevelopLangage' + G_vertical + 'html/client/_s_DevelopLangage.html',
         '7' + G_vertical + '1' + G_vertical + 'HandlerUrl' + G_vertical + 'html/client/_s_HandlerUrl.html',
         '7' + G_vertical + '1' + G_vertical + 'HandlerUrlSaveForNotes' + G_vertical + 'html/client/_s_HandlerUrlSaveForNotes.html',
         '7' + G_vertical + '1' + G_vertical + 'ServerDomain' + G_vertical + 'html/client/_s_ServerDomain.html',
         '7' + G_vertical + '1' + G_vertical + 'ToSavePathURL' + G_vertical + 'html/client/_s_ToSavePathURL.html',
         '7' + G_vertical + '1' + G_vertical + 'ToSaveFilePathURL' + G_vertical + 'html/client/_s_ToSaveFilePathURL.html',
         '7' + G_vertical + '1' + G_vertical + 'SaveFolderNameRule' + G_vertical + 'html/client/_s_SaveFolderNameRule.html',
         '7' + G_vertical + '1' + G_vertical + 'SaveFileFolderNameRule' + G_vertical + 'html/client/_s_SaveFileFolderNameRule.html',
         '7' + G_vertical + '1' + G_vertical + 'SaveFileNameRule' + G_vertical + 'html/client/_s_SaveFileNameRule.html',
         '7' + G_vertical + '1' + G_vertical + 'ImageConvertFormat' + G_vertical + 'html/client/_s_ImageConvertFormat.html',
         '7' + G_vertical + '1' + G_vertical + 'ImageConvertWidth' + G_vertical + 'html/client/_s_ImageConvertWidth.html',
         '7' + G_vertical + '1' + G_vertical + 'ImageConvertHeight' + G_vertical + 'html/client/_s_ImageConvertHeight.html',
         '7' + G_vertical + '1' + G_vertical + 'ImageAutoFit' + G_vertical + 'html/client/_s_ImageAutoFit.html',
         '7' + G_vertical + '1' + G_vertical + 'AllowMediaFileType' + G_vertical + 'html/client/_s_AllowMediaFileType.html',
         '7' + G_vertical + '1' + G_vertical + 'AllowImageFileType' + G_vertical + 'html/client/_s_AllowImageFileType.html',
         '7' + G_vertical + '1' + G_vertical + 'AllowFlashFileType' + G_vertical + 'html/client/_s_AllowFlashFileType.html',
         '7' + G_vertical + '1' + G_vertical + 'AllowInsertFileType' + G_vertical + 'html/client/_s_AllowInsertFileType.html',
         '7' + G_vertical + '1' + G_vertical + 'AttachFileImage' + G_vertical + 'html/client/_s_AttachFileImage.html',
         '7' + G_vertical + '1' + G_vertical + 'PasteImageBase64' + G_vertical + 'html/client/_s_PasteImageBase64.html',
         '7' + G_vertical + '1' + G_vertical + 'EmptyTagRemove' + G_vertical + 'html/client/_s_EmptyTagRemove.html',
        // sdk 추가 - by LimSW 22.09.21
        '7' + G_vertical + '1' + G_vertical + 'AddHttpHeader' + G_vertical + 'html/client/_s_AddHttpHeader.html',
        '7' + G_vertical + '1' + G_vertical + 'Event.AfterChangeMode' + G_vertical + 'html/client/_s_Event.AfterChangeMode.html',
        '7' + G_vertical + '1' + G_vertical + 'Event.AfterPopupShow' + G_vertical + 'html/client/_s_Event.AfterPopupShow.html',
        '7' + G_vertical + '1' + G_vertical + 'Event.BeforeInsertUrl' + G_vertical + 'html/client/_s_Event.BeforeInsertUrl.html',
        '7' + G_vertical + '1' + G_vertical + 'Event.BeforePaste' + G_vertical + 'html/client/_s_Event.BeforePaste.html',
        '7' + G_vertical + '1' + G_vertical + 'Event.Command' + G_vertical + 'html/client/_s_Event.Command.html',
        '7' + G_vertical + '1' + G_vertical + 'Event.ContentSizeChange' + G_vertical + 'html/client/_s_Event.ContentSizeChange.html',
        '7' + G_vertical + '1' + G_vertical + 'Event.DialogLoaded' + G_vertical + 'html/client/_s_Event.DialogLoaded.html',
        '7' + G_vertical + '1' + G_vertical + 'Event.FullScreen' + G_vertical + 'html/client/_s_Event.FullScreen.html',
        '7' + G_vertical + '1' + G_vertical + 'Event.Input' + G_vertical + 'html/client/_s_Event.Input.html',
        '7' + G_vertical + '1' + G_vertical + 'Event.Key' + G_vertical + 'html/client/_s_Event.Key.html',
        '7' + G_vertical + '1' + G_vertical + 'Event.LanguageDefinition' + G_vertical + 'html/client/_s_Event.LanguageDefinition.html',
        '7' + G_vertical + '1' + G_vertical + 'Event.LoadedEvent' + G_vertical + 'html/client/_s_Event.LoadedEvent.html',
        '7' + G_vertical + '1' + G_vertical + '[AD]Event.ManagerImg' + G_vertical + 'html/client/_s_Event.ManagerImg.html',
        '7' + G_vertical + '1' + G_vertical + '[AD]Event.ManagerInput' + G_vertical + 'html/client/_s_Event.ManagerInput.html',
        '7' + G_vertical + '1' + G_vertical + '[AD]Event.ManagerSelect' + G_vertical + 'html/client/_s_Event.ManagerSelect.html',
        '7' + G_vertical + '1' + G_vertical + '[AD]Event.ManagerTextArea' + G_vertical + 'html/client/_s_Event.ManagerTextArea.html',
        '7' + G_vertical + '1' + G_vertical + 'Event.Mouse' + G_vertical + 'html/client/_s_Event.Mouse.html',
        '7' + G_vertical + '1' + G_vertical + 'Event.OnError' + G_vertical + 'html/client/_s_Event.OnError.html',
        '7' + G_vertical + '1' + G_vertical + 'Event.PasteImage' + G_vertical + 'html/client/_s_Event.PasteImage.html',
        '7' + G_vertical + '1' + G_vertical + 'Event.Resized' + G_vertical + 'html/client/_s_Event.Resized.html',
        '7' + G_vertical + '1' + G_vertical + 'Event.SetComplete' + G_vertical + 'html/client/_s_Event.SetComplete.html',
        '7' + G_vertical + '1' + G_vertical + 'Event.SetForbiddenWordComplete' + G_vertical + 'html/client/_s_Event.SetForbiddenWordComplete.html',
        '7' + G_vertical + '1' + G_vertical + 'Event.SetInsertComplete' + G_vertical + 'html/client/_s_Event.SetInsertComplete.html',
        '7' + G_vertical + '1' + G_vertical + 'TabIndexObjValue' + G_vertical + 'html/client/_s_TabIndexObjValue.html',
        '7' + G_vertical + '1' + G_vertical + 'PasteImageBase64Remove' + G_vertical + 'html/client/_s_PasteImageBase64Remove.html',
        '7' + G_vertical + '1' + G_vertical + 'ViewImgBase64Source' + G_vertical + 'html/client/_s_ViewImgBase64Source.html',
        '7' + G_vertical + '1' + G_vertical + 'UseFontFamilyKeyin' + G_vertical + 'html/client/_s_UseFontFamilyKeyin.html',
        '7' + G_vertical + '1' + G_vertical + 'UseFontSizeIncDec' + G_vertical + 'html/client/_s_UseFontSizeIncDec.html',
        '7' + G_vertical + '1' + G_vertical + 'UseFontSizeKeyin' + G_vertical + 'html/client/_s_UseFontSizeKeyin.html',
        '7' + G_vertical + '1' + G_vertical + 'LetterSpacingList' + G_vertical + 'html/client/_s_LetterSpacingList.html',
        '7' + G_vertical + '1' + G_vertical + 'UseLetterSpacingIncDec' + G_vertical + 'html/client/_s_UseLetterSpacingIncDec.html',
        '7' + G_vertical + '1' + G_vertical + 'ImageEditorUse' + G_vertical + 'html/client/_s_ImageEditorUse.html',
        '7' + G_vertical + '1' + G_vertical + '[PL]PluginRoot' + G_vertical + 'html/client/_s_PluginRoot.html',
        '7' + G_vertical + '1' + G_vertical + '[PL]PluginUse' + G_vertical + 'html/client/_s_PluginUse.html',
        '7' + G_vertical + '1' + G_vertical + '[PL]PluginVersion' + G_vertical + 'html/client/_s_PluginVersion.html',
        '7' + G_vertical + '1' + G_vertical + '[PL]PrintMarginltrb' + G_vertical + 'html/client/_s_PrintMarginltrb.html',
        '7' + G_vertical + '1' + G_vertical + '[PL]UseFormPrint' + G_vertical + 'html/client/_s_UseFormPrint.html',
        '7' + G_vertical + '1' + G_vertical + '[PL]UsePrintApp' + G_vertical + 'html/client/_s_UsePrintApp.html',
        '7' + G_vertical + '1' + G_vertical + 'UseLineHeightIncDec' + G_vertical + 'html/client/_s_UseLineHeightIncDec.html',
        '7' + G_vertical + '1' + G_vertical + 'UseLineHeightKeyin' + G_vertical + 'html/client/_s_UseLineHeightKeyin.html',
        '7' + G_vertical + '1' + G_vertical + 'AutoGrowMode' + G_vertical + 'html/client/_s_AutoGrowMode.html',
        '7' + G_vertical + '1' + G_vertical + 'AdjustCellSizeAfterDeleteCell' + G_vertical + 'html/client/_s_AdjustCellSizeAfterDeleteCell.html',
        '7' + G_vertical + '1' + G_vertical + 'AdjustCurrentColorInSetApi' + G_vertical + 'html/client/_s_AdjustCurrentColorInSetApi.html',
        '7' + G_vertical + '1' + G_vertical + 'AdjustCursorInRelative' + G_vertical + 'html/client/_s_AdjustCursorInRelative.html',
        '7' + G_vertical + '1' + G_vertical + 'AdjustEmptySpan' + G_vertical + 'html/client/_s_AdjustEmptySpan.html',
        '7' + G_vertical + '1' + G_vertical + 'AdjustTextIndentInPaste' + G_vertical + 'html/client/_s_AdjustTextIndentInPaste.html',
        '7' + G_vertical + '1' + G_vertical + 'AfterPasteCaretPosition' + G_vertical + 'html/client/_s_AfterPasteCaretPosition.html',
        '7' + G_vertical + '1' + G_vertical + 'AllowImgSize' + G_vertical + 'html/client/_s_AllowImgSize.html',
        '7' + G_vertical + '1' + G_vertical + 'AllowLinkMediaCaption' + G_vertical + 'html/client/_s_AllowLinkMediaCaption.html',
        //'7' + G_vertical + '1' + G_vertical + '[PL]AllowOpenFileType' + G_vertical + 'html/client/_s_AllowOpenFileType.html',
        '7' + G_vertical + '1' + G_vertical + 'AllowUnableToDeleteMsg' + G_vertical + 'html/client/_s_AllowUnableToDeleteMsg.html',
        '7' + G_vertical + '1' + G_vertical + 'ApplyStyleEmptyTag' + G_vertical + 'html/client/_s_ApplyStyleEmptyTag.html',
        '7' + G_vertical + '1' + G_vertical + 'UseNoncreationAreaBackground' + G_vertical + 'html/client/_s_UseNoncreationAreaBackground.html',
        '7' + G_vertical + '1' + G_vertical + 'AutoFitInHolder' + G_vertical + 'html/client/_s_AutoFitInHolder.html',
        '7' + G_vertical + '1' + G_vertical + 'AutoList.Use' + G_vertical + 'html/client/_s_AutoList.Use.html',
        '7' + G_vertical + '1' + G_vertical + 'AutoMoveInitFocus.Use' + G_vertical + 'html/client/_s_AutoMoveInitFocus.Use.html',
        //'7' + G_vertical + '1' + G_vertical + 'AutoMoveInitFocus.TargetWindow' + G_vertical + 'html/client/_s_AutoMoveInitFocus.TargetWindow.html',
        '7' + G_vertical + '1' + G_vertical + 'UseAutoToolBar' + G_vertical + 'html/client/_s_UseAutoToolBar.html',
        //'7' + G_vertical + '1' + G_vertical + 'AutoToolBar.Default' + G_vertical + 'html/client/_s_AutoToolBar.Default.html',
        //'7' + G_vertical + '1' + G_vertical + 'AutoToolBar.FocusImage' + G_vertical + 'html/client/_s_AutoToolBar.FocusImage.html',
        //'7' + G_vertical + '1' + G_vertical + 'AutoToolBar.FocusInCell' + G_vertical + 'html/client/_s_AutoToolBar.FocusInCell.html',
        //'7' + G_vertical + '1' + G_vertical + 'AutoToolBar.SelectArea' + G_vertical + 'html/client/_s_AutoToolBar.SelectArea.html',
        //'7' + G_vertical + '1' + G_vertical + 'AutoToolBar.SelectedMultiCell' + G_vertical + 'html/client/_s_AutoToolBar.SelectedMultiCell.html',
        //'7' + G_vertical + '1' + G_vertical + 'AutoToolBar.SelectedSingleCell' + G_vertical + 'html/client/_s_AutoToolBar.SelectedSingleCell.html',
        '7' + G_vertical + '1' + G_vertical + 'AutoPluginUpdate' + G_vertical + 'html/client/_s_AutoPluginUpdate.html',
        '7' + G_vertical + '1' + G_vertical + 'AutoUrlDetect' + G_vertical + 'html/client/_s_AutoUrlDetect.html',
        '7' + G_vertical + '1' + G_vertical + 'IeBugFixedApplyAllBrowser' + G_vertical + 'html/client/_s_IeBugFixedApplyAllBrowser.html',
        '7' + G_vertical + '1' + G_vertical + 'IeBugFixedHyfont' + G_vertical + 'html/client/_s_IeBugFixedHyfont.html',
        '7' + G_vertical + '1' + G_vertical + 'Ie11BugFixedJASO' + G_vertical + 'html/client/_s_Ie11BugFixedJASO.html',
        '7' + G_vertical + '1' + G_vertical + 'Ie11BugFixedTypingBugInTable' + G_vertical + 'html/client/_s_Ie11BugFixedTypingBugInTable.html',
        '7' + G_vertical + '1' + G_vertical + 'BrowserSpellCheck' + G_vertical + 'html/client/_s_BrowserSpellCheck.html',
        '7' + G_vertical + '1' + G_vertical + 'CellSelectionMode' + G_vertical + 'html/client/_s_CellSelectionMode.html',
        '7' + G_vertical + '1' + G_vertical + 'CheckApplyWordBreakForTable' + G_vertical + 'html/client/_s_CheckApplyWordBreakForTable.html',
        '7' + G_vertical + '1' + G_vertical + 'CleanNestedTagOptions' + G_vertical + 'html/client/_s_CleanNestedTagOptions.html',
        '7' + G_vertical + '1' + G_vertical + 'ColorPickerInputKind' + G_vertical + 'html/client/_s_ColorPickerInputKind.html',
        '7' + G_vertical + '1' + G_vertical + 'CustomCssUrl' + G_vertical + 'html/client/_s_CustomCssUrl.html',
        '7' + G_vertical + '1' + G_vertical + 'CustomEvent' + G_vertical + 'html/client/_s_CustomEvent.html',
        '7' + G_vertical + '1' + G_vertical + 'DefaultImemode' + G_vertical + 'html/client/_s_DefaultImemode.html',
        '7' + G_vertical + '1' + G_vertical + 'DialogWindowScroll' + G_vertical + 'html/client/_s_DialogWindowScroll.html',
        '7' + G_vertical + '1' + G_vertical + 'DisableInsertImage' + G_vertical + 'html/client/_s_DisableInsertImage.html',
        '7' + G_vertical + '1' + G_vertical + 'DisableKeydown' + G_vertical + 'html/client/_s_DisableKeydown.html',
        '7' + G_vertical + '1' + G_vertical + 'DisableTabletap' + G_vertical + 'html/client/_s_DisableTabletap.html',
        '7' + G_vertical + '1' + G_vertical + 'EnforceDoctype' + G_vertical + 'html/client/_s_EnforceDoctype.html',
        '7' + G_vertical + '1' + G_vertical + 'Document.DocTitle' + G_vertical + 'html/client/_s_Document.DocTitle.html',
        //'7' + G_vertical + '1' + G_vertical + 'DragMove' + G_vertical + 'html/client/_s_DragMove.html',
        // 중복 '7' + G_vertical + '1' + G_vertical + 'DragResize' + G_vertical + 'html/client/_s_DragResize.html',
        // 중복 '7' + G_vertical + '1' + G_vertical + 'EditorBodyEditable' + G_vertical + 'html/client/_s_EditorBodyEditable.html',
        // 중복 '7' + G_vertical + '1' + G_vertical + 'EditorTabDisable' + G_vertical + 'html/client/_s_EditorTabDisable.html',
        '7' + G_vertical + '1' + G_vertical + 'EmoticonUrl' + G_vertical + 'html/client/_s_EmoticonUrl.html',
        '7' + G_vertical + '1' + G_vertical + 'EmptyTagRemoveInSetapi' + G_vertical + 'html/client/_s_EmptyTagRemoveInSetapi.html',
        '7' + G_vertical + '1' + G_vertical + 'EventForPasteImage' + G_vertical + 'html/client/_s_EventForPasteImage.html',
        '7' + G_vertical + '1' + G_vertical + 'Figure' + G_vertical + 'html/client/_s_Figure.html',
        '7' + G_vertical + '1' + G_vertical + 'FileDelimiter' + G_vertical + 'html/client/_s_FileDelimiter.html',
        '7' + G_vertical + '1' + G_vertical + 'FileFilterHtml5' + G_vertical + 'html/client/_s_FileFilterHtml5.html',
        '7' + G_vertical + '1' + G_vertical + '[PL]FileFilterPlugin' + G_vertical + 'html/client/_s_FileFilterPlugin.html',
        // 중복 '7' + G_vertical + '1' + G_vertical + 'DefaultFontFamily' + G_vertical + 'html/client/_s_DefaultFontFamily.html',
        '7' + G_vertical + '1' + G_vertical + 'DefaultFontMargin' + G_vertical + 'html/client/_s_DefaultFontMargin.html',
        // 중복 '7' + G_vertical + '1' + G_vertical + 'DefaultFontSize' + G_vertical + 'html/client/_s_DefaultFontSize.html',
        // 중복 '7' + G_vertical + '1' + G_vertical + 'ForbiddenWord' + G_vertical + 'html/client/_s_ForbiddenWord.html',
        '7' + G_vertical + '1' + G_vertical + 'ForceSaveAsServer' + G_vertical + 'html/client/_s_ForceSaveAsServer.html',
        '7' + G_vertical + '1' + G_vertical + 'Highlight' + G_vertical + 'html/client/_s_Highlight.html',
        '7' + G_vertical + '1' + G_vertical + 'HtmlprocessCustomText' + G_vertical + 'html/client/_s_HtmlprocessCustomText.html',
        '7' + G_vertical + '1' + G_vertical + 'HyperlinkProperty' + G_vertical + 'html/client/_s_HyperlinkProperty.html',
        '7' + G_vertical + '1' + G_vertical + 'IconName' + G_vertical + 'html/client/_s_IconName.html',
        '7' + G_vertical + '1' + G_vertical + 'IgnoreDifferentEditorName' + G_vertical + 'html/client/_s_IgnoreDifferentEditorName.html',
        '7' + G_vertical + '1' + G_vertical + 'ImageContinueInsertMaintainValue' + G_vertical + 'html/client/_s_ImageContinueInsertMaintainValue.html',
        '7' + G_vertical + '1' + G_vertical + 'ImageCustomPropertyDelimiter' + G_vertical + 'html/client/_s_ImageCustomPropertyDelimiter.html',
        '7' + G_vertical + '1' + G_vertical + 'ImgDefaultMargin' + G_vertical + 'html/client/_s_ImgDefaultMargin.html',
        '7' + G_vertical + '1' + G_vertical + '[PL]ImgUploadContenttype' + G_vertical + 'html/client/_s_ImgUploadContenttype.html',
        '7' + G_vertical + '1' + G_vertical + 'InitFocus' + G_vertical + 'html/client/_s_InitFocus.html',
        '7' + G_vertical + '1' + G_vertical + 'InoutdentDefaultSize' + G_vertical + 'html/client/_s_InoutdentDefaultSize.html',
        '7' + G_vertical + '1' + G_vertical + 'InsertCarriageReturn' + G_vertical + 'html/client/_s_InsertCarriageReturn.html',
        '7' + G_vertical + '1' + G_vertical + 'InsertMultiImage' + G_vertical + 'html/client/_s_InsertMultiImage.html',
        '7' + G_vertical + '1' + G_vertical + 'KeepImageOriginalSizeAutoCheck' + G_vertical + 'html/client/_s_KeepImageOriginalSizeAutoCheck.html',
        '7' + G_vertical + '1' + G_vertical + 'KeepOriginalHtml' + G_vertical + 'html/client/_s_KeepOriginalHtml.html',
        '7' + G_vertical + '1' + G_vertical + 'LetterSpacingIncDecGap' + G_vertical + 'html/client/_s_LetterSpacingIncDecGap.html',
        '7' + G_vertical + '1' + G_vertical + '[PL]LimitPasteHtml' + G_vertical + 'html/client/_s_LimitPasteHtml.html',
        '7' + G_vertical + '1' + G_vertical + 'LineHeightIncDecGap' + G_vertical + 'html/client/_s_LineHeightIncDecGap.html',
        '7' + G_vertical + '1' + G_vertical + '[AD]ManagerMode' + G_vertical + 'html/client/_s_ManagerMode.html',
        '7' + G_vertical + '1' + G_vertical + 'MiniPhotoEditor' + G_vertical + 'html/client/_s_MiniPhotoEditor.html',
        '7' + G_vertical + '1' + G_vertical + 'MoveStyleTagToHead' + G_vertical + 'html/client/_s_MoveStyleTagToHead.html',
        '7' + G_vertical + '1' + G_vertical + 'OfficeLineFix' + G_vertical + 'html/client/_s_OfficeLineFix.html',
        '7' + G_vertical + '1' + G_vertical + 'OlUlTagMode' + G_vertical + 'html/client/_s_OlUlTagMode.html',
        '7' + G_vertical + '1' + G_vertical + '[PL]OpenDocument' + G_vertical + 'html/client/_s_OpenDocument.html',
        '7' + G_vertical + '1' + G_vertical + '[PL]OpenDocument.Excel' + G_vertical + 'html/client/_s_OpenDocument.Excel.html',
        '7' + G_vertical + '1' + G_vertical + '[PL]OpenDocument.Powerpoint' + G_vertical + 'html/client/_s_OpenDocument.Powerpoint.html',
        '7' + G_vertical + '1' + G_vertical + '[PL]OpenDocument.Word' + G_vertical + 'html/client/_s_OpenDocument.Word.html',
        '7' + G_vertical + '1' + G_vertical + 'ParagraphAttributeType' + G_vertical + 'html/client/_s_ParagraphAttributeType.html',
        '7' + G_vertical + '1' + G_vertical + 'PasteRemoveSpanAbsolute' + G_vertical + 'html/client/_s_PasteRemoveSpanAbsolute.html',
        '7' + G_vertical + '1' + G_vertical + 'PasteTextLineBreak' + G_vertical + 'html/client/_s_PasteTextLineBreak.html',
        // 중복 '7' + G_vertical + '1' + G_vertical + '[PL]PasteToImage' + G_vertical + 'html/client/_s_PasteToImage.html',
        '7' + G_vertical + '1' + G_vertical + 'PasteToTextMode' + G_vertical + 'html/client/_s_PasteToTextMode.html',
        '7' + G_vertical + '1' + G_vertical + 'PasteWhenTableIsLast' + G_vertical + 'html/client/_s_PasteWhenTableIsLast.html',
        '7' + G_vertical + '1' + G_vertical + 'PersonalData' + G_vertical + 'html/client/_s_PersonalData.html',
        '7' + G_vertical + '1' + G_vertical + 'Placeholder' + G_vertical + 'html/client/_s_Placeholder.html',
        '7' + G_vertical + '1' + G_vertical + '[PL]PluginInstallType' + G_vertical + 'html/client/_s_PluginInstallType.html',
        '7' + G_vertical + '1' + G_vertical + '[PL]PluginTempPath' + G_vertical + 'html/client/_s_PluginTempPath.html',
        //'7' + G_vertical + '1' + G_vertical + 'PopupBackgroundHolderId' + G_vertical + 'html/client/_s_PopupBackgroundHolderId.html',
        '7' + G_vertical + '1' + G_vertical + 'RemoveCarriageReturnInTag' + G_vertical + 'html/client/_s_RemoveCarriageReturnInTag.html',
        '7' + G_vertical + '1' + G_vertical + 'RemoveColgroup' + G_vertical + 'html/client/_s_RemoveColgroup.html',
        '7' + G_vertical + '1' + G_vertical + 'RemoveDummyDivInHwpPaste' + G_vertical + 'html/client/_s_RemoveDummyDivInHwpPaste.html',
        '7' + G_vertical + '1' + G_vertical + 'RemoveDummyFontTagInPaste' + G_vertical + 'html/client/_s_RemoveDummyFontTagInPaste.html',
        '7' + G_vertical + '1' + G_vertical + 'RemoveDummyTag' + G_vertical + 'html/client/_s_RemoveDummyTag.html',
        '7' + G_vertical + '1' + G_vertical + 'RemoveEmptyTag' + G_vertical + 'html/client/_s_RemoveEmptyTag.html',
        '7' + G_vertical + '1' + G_vertical + 'RemoveFontType' + G_vertical + 'html/client/_s_RemoveFontType.html',
        '7' + G_vertical + '1' + G_vertical + 'RemoveHwpDummyTag' + G_vertical + 'html/client/_s_RemoveHwpDummyTag.html',
        '7' + G_vertical + '1' + G_vertical + 'RemoveImageInPasteExcel' + G_vertical + 'html/client/_s_RemoveImageInPasteExcel.html',
        '7' + G_vertical + '1' + G_vertical + 'RemoveLangAttribute' + G_vertical + 'html/client/_s_RemoveLangAttribute.html',
        '7' + G_vertical + '1' + G_vertical + 'RemoveLastBrTag' + G_vertical + 'html/client/_s_RemoveLastBrTag.html',
        '7' + G_vertical + '1' + G_vertical + 'RemoveMsoClass' + G_vertical + 'html/client/_s_RemoveMsoClass.html',
        '7' + G_vertical + '1' + G_vertical + 'RemoveTdStyleInPastePpt' + G_vertical + 'html/client/_s_RemoveTdStyleInPastePpt.html',
        '7' + G_vertical + '1' + G_vertical + 'RemoveTempFolderDataDay' + G_vertical + 'html/client/_s_RemoveTempFolderDataDay.html',
        '7' + G_vertical + '1' + G_vertical + 'ReplaceEmptySpanTagInSetapi' + G_vertical + 'html/client/_s_ReplaceEmptySpanTagInSetapi.html',
        '7' + G_vertical + '1' + G_vertical + 'ReplaceEmptyTagWithSpace' + G_vertical + 'html/client/_s_ReplaceEmptyTagWithSpace.html',
        '7' + G_vertical + '1' + G_vertical + 'ReplaceLineBreak' + G_vertical + 'html/client/_s_ReplaceLineBreak.html',
        '7' + G_vertical + '1' + G_vertical + 'ReplaceMsoStyle' + G_vertical + 'html/client/_s_ReplaceMsoStyle.html',
        '7' + G_vertical + '1' + G_vertical + 'ReplaceRgbToHex' + G_vertical + 'html/client/_s_ReplaceRgbToHex.html',
        '7' + G_vertical + '1' + G_vertical + 'ReturnEvent' + G_vertical + 'html/client/_s_ReturnEvent.html',
        '7' + G_vertical + '1' + G_vertical + 'SaveHtmlName' + G_vertical + 'html/client/_s_SaveHtmlName.html',
        '7' + G_vertical + '1' + G_vertical + 'Security' + G_vertical + 'html/client/_s_Security.html',
        '7' + G_vertical + '1' + G_vertical + 'SetAutoSave' + G_vertical + 'html/client/_s_SetAutoSave.html',
        // 중복 '7' + G_vertical + '1' + G_vertical + 'SetDefaultStyle' + G_vertical + 'html/client/_s_SetDefaultStyle.html',
        // 중복 '7' + G_vertical + '1' + G_vertical + 'ShowFontReal' + G_vertical + 'html/client/_s_ShowFontReal.html',
        // 중복 '7' + G_vertical + '1' + G_vertical + 'ShowToolBar' + G_vertical + 'html/client/_s_ShowToolBar.html',
        '7' + G_vertical + '1' + G_vertical + 'ShowTopStatusBar' + G_vertical + 'html/client/_s_ShowTopStatusBar.html',
        // 중복 '7' + G_vertical + '1' + G_vertical + 'SourceViewtype' + G_vertical + 'html/client/_s_SourceViewtype.html',
        // 중복 '7' + G_vertical + '1' + G_vertical + 'TableAutoAdjust' + G_vertical + 'html/client/_s_TableAutoAdjust.html',
        '7' + G_vertical + '1' + G_vertical + 'LimitTableInoutdent' + G_vertical + 'html/client/_s_LimitTableInoutdent.html',
        '7' + G_vertical + '1' + G_vertical + 'TableNearCellBorderStyle' + G_vertical + 'html/client/_s_TableNearCellBorderStyle.html',
        '7' + G_vertical + '1' + G_vertical + 'TableNoActionClass' + G_vertical + 'html/client/_s_TableNoActionClass.html',
        '7' + G_vertical + '1' + G_vertical + 'TableNoSelectionClass' + G_vertical + 'html/client/_s_TableNoSelectionClass.html',
        '7' + G_vertical + '1' + G_vertical + 'SetDefaultTagInEmptyCell' + G_vertical + 'html/client/_s_SetDefaultTagInEmptyCell.html',
        // 중복 '7' + G_vertical + '1' + G_vertical + 'ShowLineForBorderNone' + G_vertical + 'html/client/_s_ShowLineForBorderNone.html',
        '7' + G_vertical + '1' + G_vertical + 'SplitCellStyle' + G_vertical + 'html/client/_s_SplitCellStyle.html',
        '7' + G_vertical + '1' + G_vertical + 'UseTableBackgroundImage' + G_vertical + 'html/client/_s_UseTableBackgroundImage.html',
        '7' + G_vertical + '1' + G_vertical + 'TableUseHeight' + G_vertical + 'html/client/_s_TableUseHeight.html',
        '7' + G_vertical + '1' + G_vertical + 'TableDefaultCellPadding' + G_vertical + 'html/client/_s_TableDefaultCellPadding.html',
        '7' + G_vertical + '1' + G_vertical + 'DefaultBorderColor' + G_vertical + 'html/client/_s_DefaultBorderColor.html',
        '7' + G_vertical + '1' + G_vertical + 'UseTableBorderAttribute' + G_vertical + 'html/client/_s_UseTableBorderAttribute.html',
        '7' + G_vertical + '1' + G_vertical + 'TopStatusBarLoading' + G_vertical + 'html/client/_s_TopStatusBarLoading.html',
        '7' + G_vertical + '1' + G_vertical + 'UnderlineAndStrikeThroughMode' + G_vertical + 'html/client/_s_UnderlineAndStrikeThroughMode.html',
        '7' + G_vertical + '1' + G_vertical + 'Undo' + G_vertical + 'html/client/_s_Undo.html',
        '7' + G_vertical + '1' + G_vertical + 'DefaultBodySpace' + G_vertical + 'html/client/_s_DefaultBodySpace.html',
        '7' + G_vertical + '1' + G_vertical + 'UseEnterpriseMode' + G_vertical + 'html/client/_s_UseEnterpriseMode.html',
        '7' + G_vertical + '1' + G_vertical + 'UseGetHtmlToLowerCase' + G_vertical + 'html/client/_s_UseGetHtmlToLowerCase.html',
        // 중복 '7' + G_vertical + '1' + G_vertical + 'UseHorizontalLine' + G_vertical + 'html/client/_s_UseHorizontalLine.html',
        '7' + G_vertical + '1' + G_vertical + 'UseHtmlCorrection' + G_vertical + 'html/client/_s_UseHtmlCorrection.html',
        '7' + G_vertical + '1' + G_vertical + 'UseHtmlProcessByWorker' + G_vertical + 'html/client/_s_UseHtmlProcessByWorker.html',
        '7' + G_vertical + '1' + G_vertical + 'UseLineBreak' + G_vertical + 'html/client/_s_UseLineBreak.html',
        '7' + G_vertical + '1' + G_vertical + 'UsePersonalSetting' + G_vertical + 'html/client/_s_UsePersonalSetting.html',
        '7' + G_vertical + '1' + G_vertical + 'RemoveStyle' + G_vertical + 'html/client/_s_RemoveStyle.html',
        '7' + G_vertical + '1' + G_vertical + 'UseReplaceImage' + G_vertical + 'html/client/_s_UseReplaceImage.html',
        '7' + G_vertical + '1' + G_vertical + 'UseRuler' + G_vertical + 'html/client/_s_UseRuler.html',
        '7' + G_vertical + '1' + G_vertical + 'UseRuler (Mode2)' + G_vertical + 'html/client/_s_UseRuler (Mode2).html',
        '7' + G_vertical + '1' + G_vertical + 'UseTablePasteDialog' + G_vertical + 'html/client/_s_UseTablePasteDialog.html',
        '7' + G_vertical + '1' + G_vertical + 'UserColorPicker' + G_vertical + 'html/client/_s_UserColorPicker.html',
        '7' + G_vertical + '1' + G_vertical + 'UserJsUrl' + G_vertical + 'html/client/_s_UserJsUrl.html',
        '7' + G_vertical + '1' + G_vertical + 'WebFontCssUrl' + G_vertical + 'html/client/_s_WebFontCssUrl.html',
        '7' + G_vertical + '1' + G_vertical + 'WordCount' + G_vertical + 'html/client/_s_WordCount.html',
        // 중복 '7' + G_vertical + '1' + G_vertical + 'WrapPtagToSource' + G_vertical + 'html/client/_s_WrapPtagToSource.html',
        // 중복 '7' + G_vertical + '1' + G_vertical + 'StatusBar' + G_vertical + 'html/client/_s_StatusBar.html',
        '7' + G_vertical + '1' + G_vertical + 'ToolBar (ETC)' + G_vertical + 'html/client/_s_ToolBar (ETC).html',
        // 중복 '7' + G_vertical + '1' + G_vertical + 'AllowFlashFileType' + G_vertical + 'html/client/_s_AllowFlashFileType.html',
        // 중복 '7' + G_vertical + '1' + G_vertical + 'AllowImageFileType' + G_vertical + 'html/client/_s_AllowImageFileType.html',
        // 중복 '7' + G_vertical + '1' + G_vertical + 'AllowInsertFileType' + G_vertical + 'html/client/_s_AllowInsertFileType.html',
        // 중복 '7' + G_vertical + '1' + G_vertical + 'AllowMediaFileType' + G_vertical + 'html/client/_s_AllowMediaFileType.html',
        '7' + G_vertical + '1' + G_vertical + 'AllowVideoFileType' + G_vertical + 'html/client/_s_AllowVideoFileType.html',
        '7' + G_vertical + '1' + G_vertical + 'ImageAutoConvert' + G_vertical + 'html/client/_s_ImageAutoConvert.html',
        '7' + G_vertical + '1' + G_vertical + 'UploadMethod' + G_vertical + 'html/client/_s_UploadMethod.html',
        '7' + G_vertical + '1' + G_vertical + 'UploadImageFileObject' + G_vertical + 'html/client/_s_UploadImageFileObject.html',
        '7' + G_vertical + '1' + G_vertical + 'XssAllowUrl' + G_vertical + 'html/client/_s_XssAllowUrl.html',
        '7' + G_vertical + '1' + G_vertical + 'XssCheckAttribute' + G_vertical + 'html/client/_s_XssCheckAttribute.html',
        '7' + G_vertical + '1' + G_vertical + 'ZoomList' + G_vertical + 'html/client/_s_ZoomList.html'],
        ['7' + G_vertical + '1' + G_vertical + 'DEXT5Editor' + G_vertical + 'html/client/_m_Dext5editor.html',
         '7' + G_vertical + '1' + G_vertical + 'getEditor' + G_vertical + 'html/client/_m_getEditor.html',
         '7' + G_vertical + '1' + G_vertical + 'setEditor' + G_vertical + 'html/client/_m_setEditor.html',
         '7' + G_vertical + '1' + G_vertical + 'getUserRuntimeMode' + G_vertical + 'html/client/_m_getUserRuntimeMode.html',
         '7' + G_vertical + '1' + G_vertical + 'getDext5Dom' + G_vertical + 'html/client/_m_getDext5Dom.html',
         '7' + G_vertical + '1' + G_vertical + 'getDext5BodyDom' + G_vertical + 'html/client/_m_getDext5BodyDom.html',
         '7' + G_vertical + '1' + G_vertical + 'setHtmlContents' + G_vertical + 'html/client/_m_setHtmlContents.html',
         '7' + G_vertical + '1' + G_vertical + 'setHtmlContentsEw' + G_vertical + 'html/client/_m_setHtmlContentsEw.html',
         '7' + G_vertical + '1' + G_vertical + 'getHtmlValueExWithDocType' + G_vertical + 'html/client/_m_getHtmlValueExWithDocType.html',
         '7' + G_vertical + '1' + G_vertical + 'setHtmlValueExWithDocType' + G_vertical + 'html/client/_m_setHtmlValueExWithDocType.html',
         '7' + G_vertical + '1' + G_vertical + 'getHtmlValueEx' + G_vertical + 'html/client/_m_getHtmlValueEx.html',
         '7' + G_vertical + '1' + G_vertical + 'setHtmlValueEx' + G_vertical + 'html/client/_m_setHtmlValueEx.html',
         '7' + G_vertical + '1' + G_vertical + 'getHtmlValue' + G_vertical + 'html/client/_m_getHtmlValue.html',
         '7' + G_vertical + '1' + G_vertical + 'setHtmlValue' + G_vertical + 'html/client/_m_setHtmlValue.html',
         '7' + G_vertical + '1' + G_vertical + 'getBodyValueEx' + G_vertical + 'html/client/_m_getBodyValueEx.html',
         '7' + G_vertical + '1' + G_vertical + 'setBodyValueEx' + G_vertical + 'html/client/_m_setBodyValueEx.html',
         '7' + G_vertical + '1' + G_vertical + 'getBodyValueExLikeDiv' + G_vertical + 'html/client/_m_getBodyValueExLikeDiv.html',
         '7' + G_vertical + '1' + G_vertical + 'setBodyValueExLikeDiv' + G_vertical + 'html/client/_m_setBodyValueExLikeDiv.html',
         '7' + G_vertical + '1' + G_vertical + 'getBodyValue' + G_vertical + 'html/client/_m_getBodyValue.html',
         '7' + G_vertical + '1' + G_vertical + 'setBodyValue' + G_vertical + 'html/client/_m_setBodyValue.html',
         '7' + G_vertical + '1' + G_vertical + 'getBodyTextValue' + G_vertical + 'html/client/_m_getBodyTextValue.html',
         '7' + G_vertical + '1' + G_vertical + 'setInsertHTML' + G_vertical + 'html/client/_m_setInsertHTML.html',
         '7' + G_vertical + '1' + G_vertical + 'setInsertHTMLEx' + G_vertical + 'html/client/_m_setInsertHTMLEx.html',
         '7' + G_vertical + '1' + G_vertical + 'setInsertText' + G_vertical + 'html/client/_m_setInsertText.html',
         '7' + G_vertical + '1' + G_vertical + 'loadHtmlValueExFromURL' + G_vertical + 'html/client/_m_loadHtmlValueExFromURL.html',
         '7' + G_vertical + '1' + G_vertical + 'getImages' + G_vertical + 'html/client/_m_getImages.html',
         '7' + G_vertical + '1' + G_vertical + 'getImagesEx' + G_vertical + 'html/client/_m_getImagesEx.html',
         '7' + G_vertical + '1' + G_vertical + 'getContentsUrl' + G_vertical + 'html/client/_m_getContentsUrl.html',
         '7' + G_vertical + '1' + G_vertical + 'getServerImages' + G_vertical + 'html/client/_m_getServerImages.html',
         '7' + G_vertical + '1' + G_vertical + 'getDeletedImageUrl' + G_vertical + 'html/client/_m_getDeletedImageUrl.html',
         '7' + G_vertical + '1' + G_vertical + 'getDeletedElementsUrl' + G_vertical + 'html/client/_m_getDeletedElementsUrl.html',
         '7' + G_vertical + '1' + G_vertical + 'addUserCssUrl' + G_vertical + 'html/client/_m_addUserCssUrl.html',
         '7' + G_vertical + '1' + G_vertical + 'clearUserCssUrl' + G_vertical + 'html/client/_m_clearUserCssUrl.html',
         '7' + G_vertical + '1' + G_vertical + 'setUserCssText' + G_vertical + 'html/client/_m_setUserCssText.html',
         '7' + G_vertical + '1' + G_vertical + 'clearUserCssText' + G_vertical + 'html/client/_m_clearUserCssText.html',
         '7' + G_vertical + '1' + G_vertical + 'getToSavePathUrl' + G_vertical + 'html/client/_m_getToSavePathUrl.html',
         '7' + G_vertical + '1' + G_vertical + 'setToSavePathUrl' + G_vertical + 'html/client/_m_setToSavePathUrl.html',
         '7' + G_vertical + '1' + G_vertical + 'setSize' + G_vertical + 'html/client/_m_setSize.html',
         '7' + G_vertical + '1' + G_vertical + 'setFocusToEditor' + G_vertical + 'html/client/_m_setFocusToEditor.html',
         '7' + G_vertical + '1' + G_vertical + 'setNextTabElementId' + G_vertical + 'html/client/_m_setNextTabElementId.html',
         '7' + G_vertical + '1' + G_vertical + 'setRulerPosition' + G_vertical + 'html/client/_m_setRulerPosition.html',
         '7' + G_vertical + '1' + G_vertical + 'setEditorBodyEditable' + G_vertical + 'html/client/_m_setEditorBodyEditable.html',
         '7' + G_vertical + '1' + G_vertical + 'setFullScreen' + G_vertical + 'html/client/_m_setFullScreen.html',
         '7' + G_vertical + '1' + G_vertical + 'isEmpty' + G_vertical + 'html/client/_m_isEmpty.html',
         '7' + G_vertical + '1' + G_vertical + 'isDirty' + G_vertical + 'html/client/_m_isDirty.html',
         '7' + G_vertical + '1' + G_vertical + 'setDirty' + G_vertical + 'html/client/_m_setDirty.html',
         '7' + G_vertical + '1' + G_vertical + 'loadAutoSaveHtml' + G_vertical + 'html/client/_m_loadAutoSaveHtml.html',
         '7' + G_vertical + '1' + G_vertical + 'getAccessibility' + G_vertical + 'html/client/_m_getAccessibility.html',
         '7' + G_vertical + '1' + G_vertical + 'setAccessibility' + G_vertical + 'html/client/_m_setAccessibility.html',
         '7' + G_vertical + '1' + G_vertical + 'getAccessibilityValidation' + G_vertical + 'html/client/_m_getAccessibilityValidation.html',
         '7' + G_vertical + '1' + G_vertical + 'setAccessibilityValidation' + G_vertical + 'html/client/_m_setAccessibilityValidation.html',
         '7' + G_vertical + '1' + G_vertical + 'setEditorMode' + G_vertical + 'html/client/_m_setEditorMode.html',
         '7' + G_vertical + '1' + G_vertical + 'setEditorBorder' + G_vertical + 'html/client/_m_setEditorBorder.html',
         '7' + G_vertical + '1' + G_vertical + 'selectAll' + G_vertical + 'html/client/_m_selectAll.html',
         '7' + G_vertical + '1' + G_vertical + 'show' + G_vertical + 'html/client/_m_show.html',
         '7' + G_vertical + '1' + G_vertical + 'hidden' + G_vertical + 'html/client/_m_hidden.html',
         '7' + G_vertical + '1' + G_vertical + 'showTopMenu' + G_vertical + 'html/client/_m_showTopMenu.html',
         '7' + G_vertical + '1' + G_vertical + 'showToolbar' + G_vertical + 'html/client/_m_showToolbar.html',
         '7' + G_vertical + '1' + G_vertical + 'showStatusbar' + G_vertical + 'html/client/_m_showStatusbar.html',
         '7' + G_vertical + '1' + G_vertical + 'setEditorChangeMode' + G_vertical + 'html/client/_m_setEditorChangeMode.html',
         '7' + G_vertical + '1' + G_vertical + '[PL]dext5EncodeMime' + G_vertical + 'html/client/_m_dext5EncodeMime.html',
         '7' + G_vertical + '1' + G_vertical + 'dext5EncodeMimeEx' + G_vertical + 'html/client/_m_dext5EncodeMimeEx.html',
         '7' + G_vertical + '1' + G_vertical + '[PL]dext5DecodeMime' + G_vertical + 'html/client/_m_dext5DecodeMime.html',
         '7' + G_vertical + '1' + G_vertical + '[PL]doSaveHTML' + G_vertical + 'html/client/_m_doSaveHTML.html',
         '7' + G_vertical + '1' + G_vertical + '[PL]doPrint' + G_vertical + 'html/client/_m_doPrint.html',
         '7' + G_vertical + '1' + G_vertical + '[PL]doPrintPreview' + G_vertical + 'html/client/_m_doPrintPreview.html',
         // sdk 추가 - by LimSW 22.09.21
         '7' + G_vertical + '1' + G_vertical + 'addFormData' + G_vertical + 'html/client/_m_addFormData.html',
         '7' + G_vertical + '1' + G_vertical + 'addHtmlToSetValue' + G_vertical + 'html/client/_m_addHtmlToSetValue.html',
         '7' + G_vertical + '1' + G_vertical + '[PL]addHttpHeaderEx' + G_vertical + 'html/client/_m_addHttpHeaderEx.html',
         '7' + G_vertical + '1' + G_vertical + 'addUserD5Event' + G_vertical + 'html/client/_m_addUserD5Event.html',
         '7' + G_vertical + '1' + G_vertical + 'addUserJsUrl' + G_vertical + 'html/client/_m_addUserJsUrl.html',
         '7' + G_vertical + '1' + G_vertical + 'addWebFontCssUrl' + G_vertical + 'html/client/_m_addWebFontCssUrl.html',
         '7' + G_vertical + '1' + G_vertical + 'appendTableRow' + G_vertical + 'html/client/_m_appendTableRow.html',
         '7' + G_vertical + '1' + G_vertical + 'changeImageData' + G_vertical + 'html/client/_m_changeImageData.html',
         '7' + G_vertical + '1' + G_vertical + 'cleanNestedHtml' + G_vertical + 'html/client/_m_cleanNestedHtml.html',
         '7' + G_vertical + '1' + G_vertical + 'cleanNestedHtmlEx' + G_vertical + 'html/client/_m_cleanNestedHtmlEx.html',
         '7' + G_vertical + '1' + G_vertical + 'cleanNestedHtmlForNode' + G_vertical + 'html/client/_m_cleanNestedHtmlForNode.html',
         '7' + G_vertical + '1' + G_vertical + 'cleanNestedTag' + G_vertical + 'html/client/_m_cleanNestedTag.html',
         '7' + G_vertical + '1' + G_vertical + 'clearUserJsUrl' + G_vertical + 'html/client/_m_clearUserJsUrl.html',
         '7' + G_vertical + '1' + G_vertical + 'closeDialogPopup' + G_vertical + 'html/client/_m_closeDialogPopup.html',
         '7' + G_vertical + '1' + G_vertical + 'contentsSizeCheck' + G_vertical + 'html/client/_m_contentsSizeCheck.html',
         '7' + G_vertical + '1' + G_vertical + 'convertHtmlToText' + G_vertical + 'html/client/_m_convertHtmlToText.html',
         '7' + G_vertical + '1' + G_vertical + 'convertHWPFilter' + G_vertical + 'html/client/_m_convertHWPFilter.html',
         '7' + G_vertical + '1' + G_vertical + 'convertMMToPxUnit' + G_vertical + 'html/client/_m_convertMMToPxUnit.html',
         '7' + G_vertical + '1' + G_vertical + 'createHyperLink' + G_vertical + 'html/client/_m_createHyperLink.html',
         '7' + G_vertical + '1' + G_vertical + 'deleteDynamicTable' + G_vertical + 'html/client/_m_deleteDynamicTable.html',
         '7' + G_vertical + '1' + G_vertical + 'destroy' + G_vertical + 'html/client/_m_destroy.html',
         //'7' + G_vertical + '1' + G_vertical + 'dext5DecodeMimeEx' + G_vertical + 'html/client/_m_dext5DecodeMimeEx.html',
         //'7' + G_vertical + '1' + G_vertical + 'dext5EncodeMimeEx' + G_vertical + 'html/client/_m_dext5EncodeMimeEx.html',
         '7' + G_vertical + '1' + G_vertical + 'dextCommands' + G_vertical + 'html/client/_m_dextCommands.html',
         '7' + G_vertical + '1' + G_vertical + '[PL]doSaveHTMLEx' + G_vertical + 'html/client/_m_doSaveHTMLEx.html',
         '7' + G_vertical + '1' + G_vertical + 'editorPrint' + G_vertical + 'html/client/_m_editorPrint.html',
         '7' + G_vertical + '1' + G_vertical + 'findWord' + G_vertical + 'html/client/_m_findWord.html',
         '7' + G_vertical + '1' + G_vertical + 'getBodyLineCount' + G_vertical + 'html/client/_m_getBodyLineCount.html',
         '7' + G_vertical + '1' + G_vertical + 'getBodyTextLength' + G_vertical + 'html/client/_m_getBodyTextLength.html',
         '7' + G_vertical + '1' + G_vertical + 'getByteLength' + G_vertical + 'html/client/_m_getByteLength.html',
         '7' + G_vertical + '1' + G_vertical + 'getCaretElement' + G_vertical + 'html/client/_m_getCaretElement.html',
         '7' + G_vertical + '1' + G_vertical + 'getCaretElementEx' + G_vertical + 'html/client/_m_getCaretElementEx.html',
         '7' + G_vertical + '1' + G_vertical + 'getCaretObject' + G_vertical + 'html/client/_m_getCaretObject.html',
         '7' + G_vertical + '1' + G_vertical + 'getD5Dom' + G_vertical + 'html/client/_m_getD5Dom.html',
         '7' + G_vertical + '1' + G_vertical + 'getDext5DocumentDom' + G_vertical + 'html/client/_m_getDext5DocumentDom.html',
         '7' + G_vertical + '1' + G_vertical + 'getEditorByName' + G_vertical + 'html/client/_m_getEditorByName.html',
         '7' + G_vertical + '1' + G_vertical + 'getEditorSize' + G_vertical + 'html/client/_m_getEditorSize.html',
         '7' + G_vertical + '1' + G_vertical + 'getEditorStyle' + G_vertical + 'html/client/_m_getEditorStyle.html',
         '7' + G_vertical + '1' + G_vertical + 'getElementById' + G_vertical + 'html/client/_m_getElementById.html',
         '7' + G_vertical + '1' + G_vertical + 'getElementsByName' + G_vertical + 'html/client/_m_getElementsByName.html',
         '7' + G_vertical + '1' + G_vertical + 'getElementsByTagName' + G_vertical + 'html/client/_m_getElementsByTagName.html',
         '7' + G_vertical + '1' + G_vertical + 'getFileSize' + G_vertical + 'html/client/_m_getFileSize.html',
         '7' + G_vertical + '1' + G_vertical + 'getFileSizeEx' + G_vertical + 'html/client/_m_getFileSizeEx.html',
         '7' + G_vertical + '1' + G_vertical + 'getForbiddenWordValidation' + G_vertical + 'html/client/_m_getForbiddenWordValidation.html',
         '7' + G_vertical + '1' + G_vertical + 'getMetaTag' + G_vertical + 'html/client/_m_getMetaTag.html',
         '7' + G_vertical + '1' + G_vertical + 'getMultiValue' + G_vertical + 'html/client/_m_getMultiValue.html',
         '7' + G_vertical + '1' + G_vertical + 'getMultiValueLength' + G_vertical + 'html/client/_m_getMultiValueLength.html',
         '7' + G_vertical + '1' + G_vertical + 'getPersonalDataValidation' + G_vertical + 'html/client/_m_getPersonalDataValidation.html',
         '7' + G_vertical + '1' + G_vertical + '[PL]getPluginVersion' + G_vertical + 'html/client/_m_getPluginVersion.html',
         '7' + G_vertical + '1' + G_vertical + 'getSelectedCell' + G_vertical + 'html/client/_m_getSelectedCell.html',
         '7' + G_vertical + '1' + G_vertical + 'getSelectedContent' + G_vertical + 'html/client/_m_getSelectedContent.html',
         '7' + G_vertical + '1' + G_vertical + 'getValueInTextMode' + G_vertical + 'html/client/_m_getValueInTextMode.html',
         '7' + G_vertical + '1' + G_vertical + 'getVisibility' + G_vertical + 'html/client/_m_getVisibility.html',
         '7' + G_vertical + '1' + G_vertical + 'setVisibility' + G_vertical + 'html/client/_m_setVisibility.html',
         '7' + G_vertical + '1' + G_vertical + 'inImage' + G_vertical + 'html/client/_m_inImage.html',
         '7' + G_vertical + '1' + G_vertical + 'inputButton' + G_vertical + 'html/client/_m_inputButton.html',
         '7' + G_vertical + '1' + G_vertical + 'inputCheckbox' + G_vertical + 'html/client/_m_inputCheckbox.html',
         '7' + G_vertical + '1' + G_vertical + 'inputHiddenfield' + G_vertical + 'html/client/_m_inputHiddenfield.html',
         '7' + G_vertical + '1' + G_vertical + 'inputImagebutton' + G_vertical + 'html/client/_m_inputImagebutton.html',
         '7' + G_vertical + '1' + G_vertical + 'inputRadio' + G_vertical + 'html/client/_m_inputRadio.html',
         '7' + G_vertical + '1' + G_vertical + 'inputSelect' + G_vertical + 'html/client/_m_inputSelect.html',
         '7' + G_vertical + '1' + G_vertical + 'inputTextarea' + G_vertical + 'html/client/_m_inputTextarea.html',
         '7' + G_vertical + '1' + G_vertical + 'inputTextfield' + G_vertical + 'html/client/_m_inputTextfield.html',
         '7' + G_vertical + '1' + G_vertical + 'insertDiv' + G_vertical + 'html/client/_m_insertDiv.html',
         '7' + G_vertical + '1' + G_vertical + 'insertDynamicTable' + G_vertical + 'html/client/_m_insertDynamicTable.html',
         '7' + G_vertical + '1' + G_vertical + 'insertImg' + G_vertical + 'html/client/_m_insertImg.html',
         '7' + G_vertical + '1' + G_vertical + 'insertInput' + G_vertical + 'html/client/_m_insertInput.html',
         '7' + G_vertical + '1' + G_vertical + 'insertSelect' + G_vertical + 'html/client/_m_insertSelect.html',
         '7' + G_vertical + '1' + G_vertical + 'insertTextarea' + G_vertical + 'html/client/_m_insertTextarea.html',
         '7' + G_vertical + '1' + G_vertical + 'isEmptyToString' + G_vertical + 'html/client/_m_isEmptyToString.html',
         '7' + G_vertical + '1' + G_vertical + '[PL]isInstallSucceed' + G_vertical + 'html/client/_m_isInstallSucceed.html',
         //'7' + G_vertical + '1' + G_vertical + 'isLoadedEditor' + G_vertical + 'html/client/_m_isLoadedEditor.html',
         '7' + G_vertical + '1' + G_vertical + 'isLoadedEditorEx' + G_vertical + 'html/client/_m_isLoadedEditorEx.html',
         '7' + G_vertical + '1' + G_vertical + '[PL]isPluginInstalled' + G_vertical + 'html/client/_m_isPluginInstalled.html',
         '7' + G_vertical + '1' + G_vertical + 'loadHtmlValueExFromServerURL' + G_vertical + 'html/client/_m_loadHtmlValueExFromServerURL.html',
         '7' + G_vertical + '1' + G_vertical + 'manuallyTempSave' + G_vertical + 'html/client/_m_manuallyTempSave.html',
         '7' + G_vertical + '1' + G_vertical + 'removeClassStyle' + G_vertical + 'html/client/_m_removeClassStyle.html',
         '7' + G_vertical + '1' + G_vertical + 'removeCss' + G_vertical + 'html/client/_m_removeCss.html',
         '7' + G_vertical + '1' + G_vertical + 'removeNode' + G_vertical + 'html/client/_m_removeNode.html',
         '7' + G_vertical + '1' + G_vertical + 'replaceBlocktoBr' + G_vertical + 'html/client/_m_replaceBlocktoBr.html',
         '7' + G_vertical + '1' + G_vertical + 'replaceText' + G_vertical + 'html/client/_m_replaceText.html',
         '7' + G_vertical + '1' + G_vertical + 'replaceTextAll' + G_vertical + 'html/client/_m_replaceTextAll.html',
         //'7' + G_vertical + '1' + G_vertical + '[PL]requestPluginInstall' + G_vertical + 'html/client/_m_requestPluginInstall.html',
         '7' + G_vertical + '1' + G_vertical + 'saveCurrValueInMultiValue' + G_vertical + 'html/client/_m_saveCurrValueInMultiValue.html',
         '7' + G_vertical + '1' + G_vertical + 'setAdjustTableBorderStyle' + G_vertical + 'html/client/_m_setAdjustTableBorderStyle.html',
         '7' + G_vertical + '1' + G_vertical + 'setCaretBeforeOrAfter' + G_vertical + 'html/client/_m_setCaretBeforeOrAfter.html',
         '7' + G_vertical + '1' + G_vertical + 'setClassStyle' + G_vertical + 'html/client/_m_setClassStyle.html',
         //'7' + G_vertical + '1' + G_vertical + 'setContentsInitSize' + G_vertical + 'html/client/_m_setContentsInitSize.html',
         '7' + G_vertical + '1' + G_vertical + 'setCustomDisableIconList' + G_vertical + 'html/client/_m_setCustomDisableIconList.html',
         '7' + G_vertical + '1' + G_vertical + 'setDext5DomMode' + G_vertical + 'html/client/_m_setDext5DomMode.html',
         '7' + G_vertical + '1' + G_vertical + 'setDirectEditHtmlUrl' + G_vertical + 'html/client/_m_setDirectEditHtmlUrl.html',
         '7' + G_vertical + '1' + G_vertical + 'setEditorBodyWidth' + G_vertical + 'html/client/_m_setEditorBodyWidth.html',
         '7' + G_vertical + '1' + G_vertical + 'setElementInnerHTML' + G_vertical + 'html/client/_m_setElementInnerHTML.html',
         '7' + G_vertical + '1' + G_vertical + 'setElementInnerText' + G_vertical + 'html/client/_m_setElementInnerText.html',
         '7' + G_vertical + '1' + G_vertical + 'setFocusToObject' + G_vertical + 'html/client/_m_setFocusToObject.html',
         '7' + G_vertical + '1' + G_vertical + 'setFontBgColor' + G_vertical + 'html/client/_m_setFontBgColor.html',
         '7' + G_vertical + '1' + G_vertical + 'setFontColor' + G_vertical + 'html/client/_m_setFontColor.html',
         '7' + G_vertical + '1' + G_vertical + 'setFontFamily' + G_vertical + 'html/client/_m_setFontFamily.html',
         '7' + G_vertical + '1' + G_vertical + 'setFontFormat' + G_vertical + 'html/client/_m_setFontFormat.html',
         '7' + G_vertical + '1' + G_vertical + 'setFontSize' + G_vertical + 'html/client/_m_setFontSize.html',
         '7' + G_vertical + '1' + G_vertical + 'setForbiddenWordValidation' + G_vertical + 'html/client/_m_setForbiddenWordValidation.html',
         '7' + G_vertical + '1' + G_vertical + 'setFormDataTextValue' + G_vertical + 'html/client/_m_setFormDataTextValue.html',
         '7' + G_vertical + '1' + G_vertical + 'setHeightForDisplay' + G_vertical + 'html/client/_m_setHeightForDisplay.html',
         '7' + G_vertical + '1' + G_vertical + 'setHighlight' + G_vertical + 'html/client/_m_setHighlight.html',
         '7' + G_vertical + '1' + G_vertical + 'setInsertHTMLToObject' + G_vertical + 'html/client/_m_setInsertHTMLToObject.html',
         '7' + G_vertical + '1' + G_vertical + 'setLockCommand' + G_vertical + 'html/client/_m_setLockCommand.html',
         '7' + G_vertical + '1' + G_vertical + 'setMetaTag' + G_vertical + 'html/client/_m_setMetaTag.html',
         '7' + G_vertical + '1' + G_vertical + 'setNextValueInMultiValue' + G_vertical + 'html/client/_m_setNextValueInMultiValue.html',
         '7' + G_vertical + '1' + G_vertical + 'setOriginalHtmlValue' + G_vertical + 'html/client/_m_setOriginalHtmlValue.html',
         '7' + G_vertical + '1' + G_vertical + 'setPersonalDataValidation' + G_vertical + 'html/client/_m_setPersonalDataValidation.html',
         '7' + G_vertical + '1' + G_vertical + 'setReadOnly' + G_vertical + 'html/client/_m_setReadOnly.html',
         '7' + G_vertical + '1' + G_vertical + 'setTableEdgeReduce' + G_vertical + 'html/client/_m_setTableEdgeReduce.html',
         '7' + G_vertical + '1' + G_vertical + '[PL]setTempRootDirectory' + G_vertical + 'html/client/_m_setTempRootDirectory.html',
         '7' + G_vertical + '1' + G_vertical + 'setUserFontFamily' + G_vertical + 'html/client/_m_setUserFontFamily.html',
         '7' + G_vertical + '1' + G_vertical + 'setUserFontSize' + G_vertical + 'html/client/_m_setUserFontSize.html',
         '7' + G_vertical + '1' + G_vertical + 'setUserJsText' + G_vertical + 'html/client/_m_setUserJsText.html',
         '7' + G_vertical + '1' + G_vertical + 'clearUserJsText' + G_vertical + 'html/client/_m_clearUserJsText.html',
         '7' + G_vertical + '1' + G_vertical + 'setValueInTextMode' + G_vertical + 'html/client/_m_setValueInTextMode.html',
         //'7' + G_vertical + '1' + G_vertical + 'setVisibility' + G_vertical + 'html/client/_m_setVisibility.html',
         '7' + G_vertical + '1' + G_vertical + 'setZoom' + G_vertical + 'html/client/_m_setZoom.html'],
        ['7' + G_vertical + '1' + G_vertical + 'AfterChangeMode' + G_vertical + 'html/client/_e_AfterChangeMode.html',
         '7' + G_vertical + '1' + G_vertical + 'BeforeInsertUrl' + G_vertical + 'html/client/_e_BeforeInsertUrl.html',
         '7' + G_vertical + '1' + G_vertical + 'BeforePaste' + G_vertical + 'html/client/_e_Beforepaste.html',
         '7' + G_vertical + '1' + G_vertical + 'CustomAction' + G_vertical + 'html/client/_e_CustomAction.html',
         '7' + G_vertical + '1' + G_vertical + 'EditorLoaded' + G_vertical + 'html/client/_e_EditorLoaded.html',
         '7' + G_vertical + '1' + G_vertical + 'FullScreen' + G_vertical + 'html/client/_e_FullScreen.html',
         '7' + G_vertical + '1' + G_vertical + 'LanguageDefinition' + G_vertical + 'html/client/_e_LanguageDefinition.html',
         '7' + G_vertical + '1' + G_vertical + 'OnError' + G_vertical + 'html/client/_e_OnError.html',
         '7' + G_vertical + '1' + G_vertical + 'Resized' + G_vertical + 'html/client/_e_Resized.html',
         '7' + G_vertical + '1' + G_vertical + '[AD]EditorImg' + G_vertical + 'html/client/_e_EditorImg.html',
         '7' + G_vertical + '1' + G_vertical + '[AD]EditorInput' + G_vertical + 'html/client/_e_EditorInput.html',
         '7' + G_vertical + '1' + G_vertical + '[AD]EditorSelect' + G_vertical + 'html/client/_e_EditorSelect.html',
         '7' + G_vertical + '1' + G_vertical + '[AD]EditorTextarea' + G_vertical + 'html/client/_e_EditorTextarea.html',
         // sdk 추가 - by LimSW 22.09.21
         '7' + G_vertical + '1' + G_vertical + 'PasteImage' + G_vertical + 'html/client/_e_PasteImage.html',
         '7' + G_vertical + '1' + G_vertical + 'MouseEvent' + G_vertical + 'html/client/_e_MouseEvent.html',
         '7' + G_vertical + '1' + G_vertical + 'FocusEvent' + G_vertical + 'html/client/_e_FocusEvent.html',
         '7' + G_vertical + '1' + G_vertical + 'SetInsertComplete' + G_vertical + 'html/client/_e_SetInsertComplete.html',
         '7' + G_vertical + '1' + G_vertical + 'SetComplete' + G_vertical + 'html/client/_e_SetComplete.html',
         '7' + G_vertical + '1' + G_vertical + 'KeyEvent' + G_vertical + 'html/client/_e_KeyEvent.html',
         '7' + G_vertical + '1' + G_vertical + 'DialogLoaded' + G_vertical + 'html/client/_e_DialogLoaded.html',
         '7' + G_vertical + '1' + G_vertical + 'AfterPopupShow' + G_vertical + 'html/client/_e_AfterPopupShow.html',
         '7' + G_vertical + '1' + G_vertical + 'DragEvent' + G_vertical + 'html/client/_e_DragEvent.html',
         '7' + G_vertical + '1' + G_vertical + 'CommandEvent' + G_vertical + 'html/client/_e_CommandEvent.html',
         '7' + G_vertical + '1' + G_vertical + 'ContentsizeChange' + G_vertical + 'html/client/_e_ContentsizeChange.html',
         '7' + G_vertical + '1' + G_vertical + 'SetForbiddenWordComplete' + G_vertical + 'html/client/_e_SetForbiddenWordComplete.html',
         '7' + G_vertical + '1' + G_vertical + '[PL]BeforeOpenHtmlConvert' + G_vertical + 'html/client/_e_BeforeOpenHtmlConvert.html',
         '7' + G_vertical + '1' + G_vertical + 'InputEvent' + G_vertical + 'html/client/_e_InputEvent.html']
        ],
    []
];

var arrSearchWordMenu = [
    [
        ['설치', '기본설정', '설치 및 기본설정']
    ],
    [
        [
            ['InitXml', 'XML파일 설정', '환경설정파일 설정', '설정파일 URL 설정'],
            ['InitServerXml', 'XML파일 암호화', '환경설정파일 암호화'],
            ['InitVisible', '화면 표시 여부', '화면 노출 여부'],
            ['EditorHolder', '특정 영역에 생성', '특정 객체에 생성'],
            ['IgnoreSameEditorName', '임의로 변경 생성'],
            ['DefaultMessage', '에디터 디자인 영역에 기본으로 띄울 메세지를 설정'],
            ['DialogWindow', '에디터 팝업을 Iframe 외부 최 상단 페이지로 설정'],
            ['Doctype', '에디터 Doctype를 설정'],
            ['EditorBorder', '에디터 전체영역 보더 라인을 보이거나 숨기는 설정'],
            ['FileFieldID', '파일 업로드에 사용되는 File 태그의 name을 설정'],
            ['FirstLoadMessage', '에디터 생성 후 디자인영역에 텍스트, html 등을 띄움'],
            ['FocusInitObjId', '에디터 로드 후 설정한 아이디를 가진 객체에 포커스를 설정'],
            ['FormattingList', '에디터 기본 서식 메뉴에 노출할 서식 리스트를 설정'],
            ['NextTabElementId', 'Tab키를 입력하면 마지막 포커스가 설정한 아이디로 이동'],
            ['SetValueObjId', 'textarea에 ID 값을 설정하면 에디터 로드 후 textarea 내용이 에디터에 세팅'],
            ['TabIndexObjId', '에디터 로드 후 div 같은 객체에 포커스를 주고 싶을 때 tabindex를 0으로 설정할 id값'],
            ['UserFieldID,UserFieldValue', '파일 업로드에 사용되는 User 태그의 name과 value를 설정'],
            ['ZIndex', '에디터 배치 순서를 설정'],
            ['License', '라이선스 설정', '라이센스 설정', '발급받은 키 설정'],
            ['MimeUse', 'MIME 사용 여부를 설정'],
            ['MimeCharset', 'MIME에 사용할 문자 인코딩 형태를 설정', 'MIME에 사용할 문자 character encoding 형태를 설정'],
            ['MimeConentEncodingType', 'MIME 인코딩 시에 인코딩 방법을 설정'],
            ['MimeFileTypeFilter', 'MIME 인코딩 대상 파일을 설정'],
            ['MimeLocalOnly', 'MIME 인코딩 대상 파일 중에서 외부(Local PC가 아닌)도 포함 할 지를 설정'],
            ['MimeRemoveHeader', 'MIME 인코딩 생성 중에 Subject, DataData 및 X-Generator 값을 생성하지 않음'],
            ['PrintPreview', '인쇄 미리보기 기능 사용여부를 설정'],
            ['PrintHeader', '인쇄 시 Header 영역의 내용을 설정'],
            ['PrintFooter', '인쇄 시 Footer 영역의 내용을 설정'],
            ['TrustSites', '신뢰할 수 있는 사이트를 추가'],
            ['XssUse', '에디터 XSS 방지를 설정'],
            ['XssAllowEventsAttribute', '객체의 Attribute에 설정된 이벤트들을 허용할지 여부를 설정'],
            ['XssRemoveTags', '에디터에 입력되면 삭제할 태그를 설정'],
            ['XssRemoveEvents', '에디터에 입력되면 삭제할 이벤트를 설정'],
            ['ForbiddenWord', '금지어 설정'],
            ['TopMenu', '에디터의 메뉴바에서 메뉴를 표시하거나 숨기는 기능을 설정'],
            ['ToolBar1', '에디터의 상단(기본) 툴바의 메뉴를 표시하거나 숨기는 기능을 설정'],
            ['ToolBar2', '에디터의 하단(서식) 툴바의 메뉴를 표시하거나 숨기는 기능을 설정'],
            ['StatusBar', '에디터의 보기화면(statusBar) 메뉴를 원하는 탭으로 표시하거나 숨기는 기능을 설정'],
            ['StatusBarInitMode', '에디터 로드 시 보여질 보기화면(statusBar) 모드를 설정'],
            ['RemoveItem', '에디터에서 미표시 하려는 command를 설정'],
            ['RemoveContextItem', '에디터 우클릭 메뉴에서 미표시 하려는 command를 설정'],
            ['FontSize', '에디터 폰트 크기 메뉴에 노출할 크기 리스트를 설정'],
            ['FontFamily', '에디터 글꼴 메뉴에 노출할 폰트 리스트를 설정'],
            ['UseLocalFont', '에디터 글꼴 메뉴에 사용자 로컬 폰트 추가 여부를 설정'],
            ['UseRecentlyFont', '에디터 글꼴 메뉴에 최근사용 폰트 추가 여부를 설정'],
            ['LineHeight', '에디터 줄간격 메뉴에 노출할 줄간격 리스트를 설정'],
            ['RunTimes', '에디터 모드 설정', '웹표준모드', '플러그인모드'],
            ['Encoding', '에디터 디자인 모드에 사용할 문자 인코딩(character encoding) 형태를 설정'],
            ['IeCompatible', 'IE 랜더링 모드를 설정'],
            ['Xmlnsname', '에디터 디자인 모드에서 사용할 XHTML 문서정의 포함 유무를 설정'],
            ['Lang', '에디터에 로드 할 언어를 설정'],
            ['Width', '에디터의 너비값을 설정'],
            ['Height', '에디터의 높이값을 설정'],
            ['SkinName', '에디터의 스킨 색상을 설정'],
            ['DefaultFontFamily', '에디터 로드 시 사용할 기본 폰트를 설정'],
            ['DefaultFontSize', '에디터 로드 시 사용할 기본 폰트 크기를 설정'],
            ['DefaultLineHeight', '에디터 로드 시 사용할 기본 줄간격과 줄간격 Mode를 설정'],
            ['ShowFontReal', '에디터가 사용되는 곳에서의 실제 폰트명 및 크기를 설정'],
            ['Accessibility', '웹 접근성 단계 설정 및 웹 접근성 검증 항목 중 검증 하고자 하는 항목들을 선택하여 설정'],
            ['ShowTopMenu', '에디터 메뉴바를 보이거나 숨기는 기능을 설정'],
            ['ShowToolBar', '에디터의 상단, 하단 툴바를 보이거나 숨기는 기능을 설정'],
            ['Grouping', '에디터 아이콘 툴바 그룹핑을 설정'],
            ['ShowStatusBar', '에디터의 보기화면을 보이거나 숨기는 기능을 설정', '에디터의 statusBar를 보이거나 숨기는 기능을 설정'],
            ['StatusBarLoading', '에디터의 보기화면에서 디자인, HTML 및 미리보기, TEXT 탭 변경 시 로딩 텍스트 노출 여부를 설정', '에디터의 statusBar에서 디자인, HTML 및 미리보기, TEXT 탭 변경 시 로딩 텍스트 노출 여부를 설정'],
            ['ShowDialogPosition', '에디터 다이얼로그창이 표시될 위치를 설정'],
            ['SourceViewtype', '에디터 소스보기에서 html소스 정렬 여부를 설정'],
            ['WrapPtagToSource', 'set API가 실행될 때 block 태그를 제외한 태그는 ptag로 감싸는 설정'],
            ['UserCssUrl', '사용자가 만든 css를 에디터 영역에 설정', 'css를 항상 포함할지 여부를 설정'],
            ['XhtmlValue', '소스보기나 에디터 영역의 html 소스를 가져올 때 xhtml 형식으로 가져옴'],
            ['ViewModeAutoWidth', 'View 모드 시 에디터 안의 내용만큼 자동으로 width가 늘어남'],
            ['ViewModeAutoHeight', 'View 모드 시 에디터 안의 내용만큼 자동으로 height가 늘어남'],
            ['SystemTitle', '다이얼로그창 상단 문구 변경 시 설정'],
            ['TableAutoAdjust', '에디터에서 표 작성 및 수정 시 width, height를 자동 보정으로 설정'],
            // 아래에 새로 추가 ['UseRuler', '가로 눈금자 표시 사용여부를 설정'],
            ['AutoBodyFit', '가로 눈금자 사용 설정 시, 눈금자 포인터 위치 값 기준으로 줄내림 사용여부를 설정'],
            ['ScrollOverflow', '에디터 영역에 스크롤바를 설정'],
            ['UseHorizontalLine', '세로 기준선 표시 사용여부를 설정'],
            ['ImageBaseUrl', '에디터 이미지 기본 주소를 설정'],
            ['ContextMenuDisable', '에디터 안에서 마우스 우클릭 시 메뉴 표시 사용여부를 설정'],
            ['EnterTag', 'Enter 키를 눌렀을 때 사용하게 될 태그를 설정'],
            ['FrameFullScreen', '프레임일 경우 풀 스크린 아이콘 버튼 사용여부를 설정'],
            ['ImgDefaultSize', '이미지 다이얼로그창의 너비, 높이 기본값을 설정'],
            ['AllowInoutdentText', '표 전체 들여쓰기, 내어쓰기 또는 표 안에 텍스트만 들여쓰기, 내어쓰기 사용 여부를 설정'],
            ['TableDefaultWidth', '생성될 테이블의 너비를 설정'],
            ['TableDefaultHeight', '생성될 테이블의 높이를 설정'],
            ['TableDefaultClass', '생성될 테이블의 Class Name을 설정'],
            ['TableDefaultInoutdent', '표 들여쓰기, 내어쓰기 시 사용될 px 값을 설정'],
            ['TableInitInoutdent', '표 생성 시 들여쓰기 할 기본 px값을 설정'],
            ['TableDefaultTdHeight', '표 생성 시 td 기본 높이의 px값을 설정'],
            ['TableRowMaxCount', '표 삽입 시 행의 최대값을 설정'],
            ['TableColMaxCount', '표 삽입 시 열의 최대값을 설정'],
            ['AdjustCursorInTable', '에디터에서 자체 처리된 크롬, 오페라, 사파리 브라우저에서의 방향키로 셀간 커서 이동 기능 사용여부를 설정'],
            ['TableClassList', '테이블에 지정 가능한 class명을 설정'],
            ['TableLineStyleList', '테이블에 선모양 기본 스타일을 설정'],
            ['TableNoResizeClass', '테이블에 resize 사용여부를 설정'],
            ['TableInsertDragSize', '표 삽입 메뉴의 최대 선택 개수 설정'],
            ['ShowLineForBorderNone', '테이블에 선이 없을 경우 점선 사용여부를 설정'],
            ['UseMouseTableInoutdent', '마우스로 테이블 들여쓰기,내어쓰기 사용여부를 설정'],
            ['SetDefaultStyle', '에디터 로드 시 기본 스타일이 없을 경우 body 영역에 에디터 스타일을 설정'],
            ['PasteToImage', '에디터 마우스 우클릭 시 이미지로 붙여넣기 항목을 설정'],
            ['EditorTabDisable', '디자인영역에서 tab키 입력 시 공백 입력을 설정'],
            ['RemoveSpaceInTagname', '에디터 태그 이름에 공백을 제거'],
            ['ViewModeBrowserMenu', '에디터 View 모드에서 우클릭 시 브라우저 메뉴를 열리게 함'],
            ['ViewModeAllowCopy', '에디터 View 모드에서 키보드 단축키 ctrl+c 사용을 허용 설정'],
            ['DragAndDropAllow', '에디터 마우스 Drag&Drop으로 이미지를 추가'],
            ['FormListUrl', '에디터 템플릿 양식 파일경로를 설정'],
            ['Mode', '에디터의 작성영역 모드를 설정'],
            ['Resizebar', '에디터 높이를 조절 기능 사용여부를 설정'],
            ['DragResize', '에디터 또는 브라우저의 기본 리사이즈 사용여부를 설정'],
            ['RemoveComment', '에디터에 내용이 들어올 때 주석 삭제 여부를 설정'],
            ['UserHelpUrl', '에디터 사용자 매뉴얼 경로를 설정', '에디터 사용자 help 폴더 경로를 설정'],
            ['EditorBodyEditable', '디자인 영역에 작성 가능 여부를 설정'],
            ['UseCorrectInOutdent', '붙여넣기 시 p태그의 text-indent 또는 margin-left 값이 음수인 경우에 보정'],
            ['Ie11Jaso', 'ie11브라우저에서 에디터 사용 시 자소분리 현상 보정 여부를 설정'],
            ['AutoDestroy', '에디터 언로드 시 메모리 해제 여부를 설정'],
            ['EncryptParam', '에디터에서 파일을 업로드 할 경우 파라미터 암호화에 대한 설정'],
            ['UseHtml5mode', 'HTML5가 지원되는 브라우저에서 파일 업로드시 HTML5에서 지원되는 파일첨부기능 사용여부를 설정'],
            ['DevelopLangage', '개발 언어를 설정'],
            ['HandlerUrl', '에디터 handler url을 설정'],
            ['HandlerUrlSaveForNotes', 'IBM NOTES서버에서 파일을 받을 경로를 설정'],
            ['ServerDomain', '이미지, 미디어 파일을 올릴 때 웹 경로에 들어가는 업로드 된 파일의 도메인 부분을 설정'],
            ['ToSavePathURL', '이미지, Flash, Media 파일 등을 저장 할 때 서버에 연결 된 저장소의 URL 경로를 지정'],
            ['ToSaveFilePathURL', '이미지 또는 파일 삽입 등 저장 할 때 서버에 연결 된 저장소의 URL 경로를 지정'],
            ['SaveFolderNameRule', 'ToSavePathUrl에 설정된 폴더 하위들의 저장 체계를 설정'],
            ['SaveFileFolderNameRule', 'ToSaveFilePathUrl에 설정된 폴더 하위들의 저장 체계를 설정'],
            ['SaveFileNameRule', '웹에서 등록된 파일의 이름을 지정하는 규칙'],
            ['ImageConvertFormat', '이미지 파일 업로드시 bmp 파일이나 디지털 카메라로 찍은 고용량 이미지의 크기를 줄이고자 할 때 사용하는 옵션'],
            ['ImageConvertWidth', '이미지파일 업로드 시 저장될 이미지의 너비를 변환 할 때 사용하는 옵션'],
            ['ImageConvertHeight', '이미지파일 업로드 시 저장될 이미지의 높이를 변환 할 때 사용하는 옵션'],
            ['ImageAutoFit', '이미지파일 업로드시 에디터 화면 너비에 맞게 표시할지 여부를 설정'],
            ['AllowMediaFileType', '동영상 삽입 시 허용할 확장자를 설정'],
            ['AllowImageFileType', '이미지 삽입 시 허용할 확장자를 설정'],
            ['AllowFlashFileType', '플래시 삽입 시 허용할 확장자를 설정'],
            ['AllowInsertFileType', '파일 삽입 시 허용할 확장자를 설정'],
            ['AttachFileImage', '파일 삽입 시 파일 관련 이미지 삽입을 설정'],
            ['PasteImageBase64', '이미지를 붙여넣기 할 때 DEXT5 Handler를 사용하지 않고, IMG의 src 값을 base64로 처리'],
            ['EmptyTagRemove', '붙여넣기 할 때 P태그 안에 내용이 없으면 삭제처리'],
            ['AddHttpHeader', 'request header를 설정하여 추가'],
            ['Event.AfterChangeMode', 'dext_editor_afterchangemode_event를 설정', '에디터 보기화면(statusBar) 변경 후 이벤트가 발생'],
            ['Event.AfterPopupShow', 'dext_editor_afterpopupshow_event를 설정', '각종 팝업 발생시 이벤트가 발생'],
            ['Event.BeforeInsertUrl', 'dext_editor_before_insert_url_event를 설정', '에디터에 파일 업로드 후 url 삽입 전에 이벤트가 발생'],
            ['Event.BeforePaste', 'dext_editor_beforepaste_event를 설정', '에디터에 붙여넣기 전 이벤트가 발생'],
            ['Event.Command', 'dext_command_event를 설정', '에디터 기능(아이콘) 수행시 이벤트가 발생'],
            ['Event.ContentSizeChange', 'dext_editor_contentsize_change_event를 설정', '에디터에 content를 추가하거나 제거하여 총 size 합의 값이 변경되면 이벤트가 발생'],
            ['Event.DialogLoaded', 'dext_editor_dialog_loaded_event를 설정', '각종 dialog가 open되었을시 이벤트가 발생'],
            ['Event.FullScreen', 'dext_full_screen_event를 설정', '에디터 화면전환(전체화면, 기본화면)시 이벤트가 발생'],
            ['Event.Input', 'dext_input_event를 설정', '에디터 body에 conetent를 붙여넣기 하거나 키보드 입력으로 텍스트를 입력, 에디터 body의 작성내용이 지워질 때마다 발생'],
            ['Event.Key', 'dext_key_event를 설정', '에디터 body에서 모든 키보드 동작시 이벤트가 발생'],
            ['Event.LanguageDefinition', 'dext_editor_language_definition_event를 설정', '에디터 생성중 언어별 텍스트관련 이벤트가 발생'],
            ['Event.LoadedEvent', 'dext_editor_loaded_event를 설정', '에디터가 로드 완료(작업준비) 되었을 때 이벤트가 발생'],
            ['[AD]Event.ManagerImg', 'dext_editor_img_event를 설정', '관리자모드에서 image태그로 추가된 객체를 더블클릭 시 이벤트가 발생'],
            ['[AD]Event.ManagerInput', 'dext_editor_input_event를 설정', '관리자모드에서 input태그로 추가된 객체를 더블클릭 시 이벤트가 발생'],
            ['[AD]Event.ManagerSelect', 'dext_editor_select_event를 설정', '관리자모드에서 select태그로 추가된 객체를 더블클릭 시 이벤트가 발생'],
            ['[AD]Event.ManagerTextArea', 'dext_editor_textarea_event를 설정', '관리자모드에서 TextArea태그로 추가된 객체를 더블클릭 시 이벤트가 발생'],
            ['Event.Mouse', 'dext_mouse_event를 설정', '에디터 body에서 모든 마우스 동작시 이벤트가 발생'],
            ['Event.OnError', 'dext_editor_on_error_event를 설정', '에디터 에러가 발생할 경우 이벤트가 발생'],
            ['Event.PasteImage', 'dext_paste_image_event를 설정', '이미지를 붙여넣기 한 후 (완료 후) 이벤트가 발생'],
            ['Event.Resized', 'dext_editor_resized_event를 설정', 'resizebar를 통해 에디터 높이가 변경될 시 이벤트가 발생'],
            ['Event.SetComplete', 'dext_editor_set_complete_event를 설정', 'set API 실행 후 종료되면 발생'],
            ['Event.SetForbiddenWordComplete', '금지어 추출 다이얼로그가 적용, 취소, 닫기 등으로 꺼지면 이벤트가 발생'],
            ['Event.SetInsertComplete', 'dext_editor_set_insert_complete_event를 설정', 'setInsert API 실행 후 종료되면 발생'],
            ['TabIndexObjValue', '에디터 로드 후 파라미터로 설정된 id를 가진 객체의 tabindex를 설정'],
            ['PasteImageBase64Remove', '이미지를 붙여넣기 할 때 base64이미지를 삭제처리'],
            ['ViewImgBase64Source', '소스보기 모드에서 이미지 src를 base64 그대로 노출하도록 설정'],
            ['UseFontFamilyKeyin', 'tool bar의 글꼴 콤보박스에서 키보드 입력(문자입력) 하여 선택 가능하도록 설정'],
            ['UseFontSizeIncDec', 'tool bar의 글자 크기 콤보박스옆 위아래 클릭도구를 사용여부를 설정'],
            ['UseFontSizeKeyin', 'tool bar의 글자 크기 콤보박스에서 키보드 입력(문자입력) 하여 선택 가능하도록 설정'],
            ['LetterSpacingList', '에디터 글자간격 메뉴에 노출할 크기 리스트를 설정'],
            ['UseLetterSpacingIncDec', 'tool bar의 글자 간격 콤보박스옆 위아래 클릭도구를 사용여부를 설정'],
            ['ImageEditorUse', '미니 이미지 편집기 사용여부를 설정'],
            ['[PL]PluginRoot', 'plugin 폴더의 root 주소를 설정'],
            ['[PL]PluginUse', 'runtime을 ieplugin모드로 설정'],
            ['[PL]PluginVersion', '플러그인 버전을 설정'],
            ['[PL]PrintMarginltrb', '인쇄 미리보기 페이지 상하좌우 여백을 설정'],
            ['[PL]UseFormPrint', '이미지 캡쳐 방식의 프린트 기능 사용여부를 설정'],
            ['[PL]UsePrintApp', '오픈 소스 프린트 방식 사용여부를 설정'],
            ['UseLineHeightIncDec', 'tool bar의 줄간격 콤보박스옆 위아래 클릭도구를 사용여부를 설정'],
            ['UseLineHeightKeyin', 'tool bar의 줄간격 콤보박스에서 키보드 입력(문자입력) 하여 선택 가능하도록 설정'],
            ['AutoGrowMode', '붙여넣기시 에디터 영역의 크기 초과시 자동으로 확장되는 AutoGrowMode 활성화 여부를 설정'],
            ['AdjustCellSizeAfterDeleteCell', '표 가로줄, 세로줄 삭제 후 td높이에 따라 셀들의 크기를 조정해 주도록 설정'],
            ['AdjustCurrentColorInSetApi', 'set API 사용시 태그의 style중 border에 currentcolor 값을 실제 색상값으로 변경해 주도록 설정'],
            ['AdjustCursorInRelative', 'IE 브라우저에서 span 태그에 position: relative 스타일이 적용되어 있을경우 마우스 클릭 시 커서 이동이 되는 현상을 보정 하도록 설정'],
            ['AdjustEmptySpan', 'get API 사용시 빈 span 태그에 &amp;nbsp; 또는 br태그를 넣어주는 옵션을 설정'],
            ['AdjustTextIndentInPaste', '워드에서 붙여넣기 시 margin left 값과 textindent 값을 보정해 주도록 설정'],
            ['AfterPasteCaretPosition', '붙여넣기 후 커서 위치가 문단의 처음 또는 끝으로 이동하도록 설정'],
            ['AllowImgSize', '다이얼로그에서 이미지 삽입시 가로 세로 크기설정의 사용여부를 설정'],
            ['AllowLinkMediaCaption', '외부동영상 공유 다이얼로그에서 설명작성(caption) 부분의 활성화 여부를 설정'],
            ['AllowUnableToDeleteMsg', 'IE 브라우저에서 선택 영역 삭제시에 표의 일부가 들어있을때 알림메세지를 출력하도록 설정'],
            ['ApplyStyleEmptyTag', '내용이 없는 빈 영역에도 서식 또는 스타일을 적용하도록 설정'],
            ['UseNoncreationAreaBackground', '비 작성영역에 배경색을 적용하도록 설정'],
            ['AutoFitInHolder', '특정 태그(table, img)들을 영역의 크기에 맞게 사이즈를 조정해 주도록 설정'],
            ['AutoList.Use', '글 작성시 자동글머리 사용여부를 설정'],
            ['AutoMoveInitFocus.Use', '에디터 생성 후 자동으로 원래 포커스를 가지고 있던 객체에 포커스를 이동시켜 주도록 설정'],
            ['UseAutoToolBar', '모바일 환경에서 Auto toolbar 기능 사용여부를 설정'],
            ['AutoPluginUpdate', '플러그인의 자동 업데이트 사용여부를 설정'],
            ['AutoUrlDetect', 'URL , Mail 입력시 A태그를 자동생성 하도록 설정'],
            ['IeBugFixedApplyAllBrowser', '테이블 align 제거와 관련하여 IE브라우저 및 타 브라우저가 동일하게 반영되도록 설정'],
            ['IeBugFixedHyfont', 'IE11브라우저에서 에디터 사용 시 HY폰트의 깨짐 현상을 보정'],
            ['Ie11BugFixedJASO', 'ie11브라우저에서 에디터 사용 시 자소분리 현상 및 align 속성 보정 여부를 설정'],
            ['Ie11BugFixedTypingBugInTable', 'IE11 브라우저 사용중 셀 안의 p태그가 비어있을 경우 br 태그를 추가하여 한글 입력이 오동작 하는 현상을 보정'],
            ['BrowserSpellCheck', '브라우저에서 제공하는 맞춤법검사의 사용여부를 설정'],
            ['CellSelectionMode', '셀을 셀렉션 할 때 텍스트를 포함하여 셀렉션 하도록 설정'],
            ['CheckApplyWordBreakForTable', '모든 테이블내에서 줄바꿈을 단어 단위로 적용하도록 설정'],
            ['CleanNestedTagOptions', '중복 태그 제거 사용 시 태그 정리 기능을 설정'],
            ['ColorPickerInputKind', 'Color Picker의 색상 입력 방식을 설정'],
            ['CustomCssUrl', '파일명을 포함한 파일경로를 입력'],
            ['CustomEvent', '각 태그의 tag의 class명 또는 alt가 설정된 값과 같으면 더블클릭시 설정된 값을 command로 하여 dext_editor_custom_action을 호출하도록 설정'],
            ['DefaultImemode', 'IE 8 이하에서 에디터 로드시 한글입력으로 로드하도록 설정'],
            ['DialogWindowScroll', '넥사크로 전용 모듈에서 다이얼로그 활성화 시 에디터보다 작을 경우 스크롤 가능하도록 설정'],
            ['DisableInsertImage', '모든 이미지를 삽입(업로드)하는 기능을 제한하도록 설정'],
            ['DisableKeydown', '에디터에 delete와 backspace를 제외한 모든 키입력을 return false(미적용) 하도록 설정'],
            ['DisableTabletap', '표에서 tab 입력시 셀 이동 제한여부를 설정'],
            ['EnforceDoctype', '에디터의 doctype을 강제로 None으로 설정'],
            ['Document.DocTitle', '에디터 내부 body영역(작성영역) iframe의 title을 설정'],
            ['EmoticonUrl', '이모티콘 리스트를 설정하는 파일경로를 설정 및 적용'],
            ['EmptyTagRemoveInSetapi', 'set API 사용시 비어있는 b, i, span 태그등을 삭제하도록 작업을 수행'],
            ['EventForPasteImage', '이미지 붙여넣기 시 이벤트(dext_paste_image_event) 발생여부를 설정'],
            ['Figure', '이미지 추가시 이미지 설명에 대한 설정들을 적용'],
            ['FileDelimiter', '파일구분자를 설정', '입력값을 유니코드값으로 하여 변환된 문자열을 구분자로 설정'],
            ['FileFilterHtml5', '웹표준 모드에서 이미지 삽입 dialog 창의 filter 기능을 추가'],
            ['[PL]FileFilterPlugin', '플러그인 모드에서 이미지 삽입 dialog 창의 filter 기능을 추가'],
            ['DefaultFontMargin', '텍스트 폰트의 위, 아래 기본 여백(margin-top, margin-bottom)을 설정'],
            ['ForceSaveAsServer', '파일로 저장시 서버에서 내려주도록 설정'],
            ['Highlight', '검색 하이라이팅(setHighlight API) 기능 사용여부를 설정', '검색 하이라이팅 시 적용할 하이라이트 색을 설정'],
            ['HtmlprocessCustomText', '에디터의 프로세스 로딩 문구를 설정'],
            ['HyperlinkProperty', '하이퍼링크 삽입 다이얼로그 및 하이퍼링크 속성을 설정'],
            ['IconName', '설정한 값의 editor_"icon_name".css 파일을 불러오고 icon image url의 파일명도 해당 icon_name으로 호출'],
            ['IgnoreDifferentEditorName', '에디터를 하나만 생성한 이후 API 사용중 아이디를 잘못 넣을 시 무시하도록 설정', '에디터를 하나만 생성한 이후 에디터 ID로 인한 Alert가 발생하지 않도록 설정'],
            ['ImageContinueInsertMaintainValue', '웹표준모드에서 이미지 계속 삽입시 width,height,id를 제외한 나머지 값의 유지여부를 설정'],
            ['ImageCustomPropertyDelimiter', '이미지 삽입시 img태그에 커스텀 프로퍼티를 셋팅하기 원할 때 사용', '서버 Response 값 또는 이미지 url 삽입전 이벤트에서 설정할 프로퍼티 구분자를 설정'],
            ['ImgDefaultMargin', '이미지 다이얼로그의 상, 하, 좌, 우 기본 여백을 설정', '이미지 삽입시가 아닌 다이얼로그 팝업시 기본적으로 입력되어있는 값을 설정'],
            ['[PL]ImgUploadContenttype', '이미지 삽입시 content Type의 MIME 형태 적용 여부를 설정'],
            ['InitFocus', '에디터 로드시 에디터 작성영역에 대한 focus의 여부를 설정'],
            ['InoutdentDefaultSize', '들여쓰기 및 내어쓰기의 기본 크기값을 설정'],
            ['InsertCarriageReturn', 'get Api 호출 시 p태그와 br태그뒤에 carriage_return 삽입여부를 설정'],
            ['InsertMultiImage', '이미지 삽입시 여러장의 이미지를 한번에 선택하여 삽입 가능 여부를 설정'],
            ['KeepImageOriginalSizeAutoCheck', '이미지삽입 다이얼로그에서 파일 추가 시 원본크기 유지 항목의 자동체크 여부를 설정'],
            ['KeepOriginalHtml', 'html에 포함되어 있는 \t, \n 등의 문자를 지우지 않고 원본 그대로를 유지하는 옵션의 사용 여부를 설정'],
            ['LetterSpacingIncDecGap', 'tool bar의 글자 간격 콤보박스옆 위아래 클릭도구를 사용시 증감정도를 설정'],
            ['[PL]LimitPasteHtml', '엑셀, ppt등 에서 붙여넣을 때 HTML로 붙여넣기시 설정한 크기에 따라 붙여넣기를 비활성화 여부를 설정', '붙여넣기시 내용이 많을 경우를 체크할 때 사용'],
            ['LineHeightIncDecGap', 'tool bar의 줄 간격 콤보박스옆 위아래 클릭도구를 사용시 증감정도를 설정'],
            ['[AD]ManagerMode', '관리자모드에 관련된 설정을 적용'],
            ['MiniPhotoEditor', '미니 이미지 편집기에 관련된 설정을 적용'],
            ['MoveStyleTagToHead', 'set API 사용시 body 안에 있는 style태그를 작성영역의 head 태그 안으로 위치하도록 설정'],
            ['OfficeLineFix', 'PPT, EXCEL에서 html을 get 할 때 테두리 누락을 방지하도록 설정'],
            ['OlUlTagMode', 'set API 사용시 개선된 글머리 기호, 번호의 사용여부를 설정'],
            ['[PL]OpenDocument', '파일 열기 관련 설정을 적용'],
            ['[PL]OpenDocument.Excel', '엑셀파일의 열기 관련 설정을 적용'],
            ['[PL]OpenDocument.Powerpoint', '파워포인트파일의 열기 관련 설정을 적용'],
            ['[PL]OpenDocument.Word', '워드파일의 열기 관련 설정을 적용'],
            ['ParagraphAttributeType', '문단속성 항목의 들여쓰기, 여백의 길이 단위를 추가, 설정'],
            ['PasteRemoveSpanAbsolute', '붙여넣기 시 표가 position absolute 속성을 가진 span 태그 안에 있는 경우 absolute 속성의 제거여부를 설정'],
            ['PasteTextLineBreak', '텍스트 붙여넣기시 <br> 대신 p 태그로 줄바꿈 되도록 설정'],
            ['PasteToTextMode', '텍스트로 붙여넣기 실행 시 p태그로 감싸지 않고 붙여넣기 하도록 설정'],
            ['PasteWhenTableIsLast', '붙여넣기 시 테이블이 마지막에 있으면 아래에 p태그를 추가하여 추가된 p태그에 커서가 가도록 설정'],
            ['PersonalData', '개인정보 추출시 추출하게될 항목들을 설정'],
            ['Placeholder', '에디터 Body 내부에 아무글도 작성 안했을 때 표시되는 기본문구의 내용 및 CSS를 설정'],
            ['[PL]PluginInstallType', 'plugin 설치관련 내용을 설정합니다.'],
            ['[PL]PluginTempPath', '플러그인 temp폴더를 설정'],
            ['RemoveCarriageReturnInTag', '태그 내부(<태그명 .....>)에 줄바꿈 문자가 있으면 치환하도록 설정'],
            ['RemoveColgroup', '붙여넣기 시 테이블의 colgroup을 유지/삭제 하도록 설정'],
            ['RemoveDummyDivInHwpPaste', '한글 문서 내용 복사/붙여넣기 시 필요하지 않은 div 태그가 들어가는 현상을 보정하도록 설정'],
            ['RemoveDummyFontTagInPaste', 'html 내용 복사/붙여넣기 시 IE 브라우저에서 자동으로 생기는 font 태그를 삭제하도록 설정'],
            ['RemoveDummyTag', 'set API 사용시 <smtp: …> 와 같은 불필요 태그를 set하기 전에 제거하도록 설정'],
            ['RemoveEmptyTag', 'get API 사용시 내용이 없는 빈 태그 삭제 여부을 적용', 'set API 사용시 내용이 없는 빈 태그 삭제 여부을 적용'],
            ['RemoveFontType', '엑셀에서 복사/붙여넣기시 삭제할 type/font_family를 설정', '엑셀에서 복사/붙여넣기 시 monospace로 인해 글꼴 표시가 안되는 현상을 방지하기 위해 사용'],
            ['RemoveHwpDummyTag', '한글 붙여넣기시 Dummy tag가 들어있는 경우 삭제하도록 설정'],
            ['RemoveImageInPasteExcel', '엑셀 내용 붙여넣기 시 이미지를 제거하도록 설정'],
            ['RemoveLangAttribute', 'set API 사용시 태그안에 있는 lang attribute를 제거하도록 설정'],
            ['RemoveLastBrTag', 'set html API 사용 시 p태그 안에서 마지막 node가 br인 경우 해당 br태그를 삭제하도록 설정', '마지막에 연속으로 br태그가 있는 경우는 제외'],
            ['RemoveMsoClass', 'set API사용 또는 붙여넣기 시 Mso로 시작하는 클래스를 지울지에 대하여 설정'],
            ['RemoveTdStyleInPastePpt', 'PPT에서 테이블 복사후 에디터에 붙여넣기 시 TD에 적용되는 Default Style을 제거하도록 설정'],
            ['RemoveTempFolderDataDay', 'temp폴더의 삭제 주기를 설정'],
            ['ReplaceEmptySpanTagInSetapi', 'set API사용시 빈 span태그에 보이지 않는 문자열의 삽입여부를 설정'],
            ['ReplaceEmptyTagWithSpace', 'get API 사용시 빈 태그를 &nbsp로 치환하도록 설정'],
            ['ReplaceLineBreak', 'get API 사용시 줄바꿈을 공백으로 치환하도록 설정'],
            ['ReplaceMsoStyle', '에디터에서 엑셀내용 복사시 Mso Style 삭제하지 않고 Mso -> dext로 치환하여 속성값으로 추가하도록 설정'],
            ['ReplaceRgbToHex', 'get API 사용시 style의 rgb 값을 hex 값으로 변경하도록 설정'],
            ['ReturnEvent', '에디터의 이벤트들의 활성화/비활성화 여부를 설정'],
            ['SaveHtmlName', 'html 저장 시 html 파일명을 설정'],
            ['Security', '에디터에서 파일을 업로드 할 경우 암호화, 파일변조와 같은 보안에 관련된 설정'],
            ['SetAutoSave', '에디터에서 자동저장에 관련된 기능을 설정'],
            ['ShowTopStatusBar', '우측 최상단에 status bar의 표시여부를 설정'],
            ['LimitTableInoutdent', '테이블 들여쓰기/내어쓰기가 에디터 작성영역 안에서만 되도록 설정'],
            ['TableNearCellBorderStyle', '테이블 근접 셀에 border 스타일을 적용하도록 설정'],
            ['TableNoActionClass', '특정 class의 tabel 객체를 동작하지 않도록 설정'],
            ['TableNoSelectionClass', '특정 class의 tabel 객체를 selection이 불가능하도록 설정'],
            ['SetDefaultTagInEmptyCell', '셀을 마우스 클릭 또는 셀로 키보드 커서 이동 시 빈 셀에 p태그를 삽입'],
            ['SplitCellStyle', '셀 나누기 동작시 나눠진 각 셀에 기존 셀 서식의 유지여부를 설정'],
            ['UseTableBackgroundImage', '테이블의 이미지 배경 사용여부를 설정'],
            ['TableUseHeight', '상세 표 삽입 기능에서 템플릿으로 생성 시 생성된 테이블태그에 height값의 존재여부를 설정'],
            ['TableDefaultCellPadding', '표 생성 시 셀 안쪽의 기본 여백(cellpadding)을 설정'],
            ['DefaultBorderColor', '표 생성 시 테이블의 기본 선 색상을 설정'],
            ['UseTableBorderAttribute', '표 생성 시 table 태그의 border 속성의 유무를 설정'],
            ['TopStatusBarLoading', '우측 상단의 topStatusBar에서 "디자인", "HTML" 및 "미리보기", "TEXT" 탭 변경 시 로딩 텍스트 노출 여부를 설정'],
            ['UnderlineAndStrikeThroughMode', '언더라인, 취소선을 span의 style로 적용 또는 u, s태그로 적용을 선택하여 설정'],
            ['Undo', 'Undo, Redo에 관련된 내용을 설정'],
            ['DefaultBodySpace', '에디터 작성영역의 기본 여백 사용을 설정'],
            ['UseEnterpriseMode', '엔터프라이즈 모드를 사용하는 환경일 시 해당 환경임을 알려주도록 설정'],
            ['UseGetHtmlToLowerCase', 'get API 사용 시 대문자인 tag명을 모두 소문자로 변경해주도록 설정'],
            ['UseHtmlCorrection', 'set API 사용시 htmlparser로직(사용)의 실행 여부 및 parser의 동작을 설정'],
            ['UseHtmlProcessByWorker', 'HTML 처리 및 set API 사용시 Web Worker의 사용 여부를 설정'],
            ['UseLineBreak', '줄 바꿈 기능 사용 여부 및 줄 바꿈 기준, 가로길이를 설정'],
            ['UsePersonalSetting', '환경설정 다이얼로그의 개인화 기능을 설정'],
            ['RemoveStyle', 'set API 사용시 태그의 스타일 삭제여부 및 삭제 조건을 설정'],
            ['UseReplaceImage', '작성중 iframe, flash 등에 대체이미지를 사용하는 기능의 활성화 여부를 설정'],
            ['UseRuler', 'use_ruler의 mode가 "2"일 때의 기능 설정'],
            ['UseRuler (mode2)', 'use_ruler의 mode가 "2"일 때의 기능 설정'],
            ['UseTablePasteDialog', '표 안에서 표 붙여넣기 시 붙여넣기 관련 팝업창 사용여부를 설정'],
            ['UserColorPicker', '사용자 정의 color picker를 설정'],
            ['UserJsUrl', '에디터 로드시 사용자의 js를 에디터 body의 head부분에 import 해주도록 설정'],
            ['WebFontCssUrl', '에디터 로드시 사용자의 web font CSS를 에디터 body의 head부분에 import 해주도록 설정'],
            ['WordCount', '에디터 우측 하단에 글자수와 행의 표시유무 및 글자수 제한, 공백포함 글자수, alert 출력여부 등을 설정'],
            ['ToolBar (ETC)', '전체화면시 에디터 전체영역의 inset값(top, right, bottom, left)을 설정', 'help start page를 dext5 소개 페이지로 할지의 여부를 설정'],
            ['AllowVideoFileType', '비디오 삽입 시 허용할 확장자를 설정'],
            ['ImageAutoConvert', '붙여넣기 또는 드래그앤 드랍으로 이미지 삽입 시 설정된 width, height 값에 맞춰 이미지 크기의 비율 조정여부를 설정'],
            ['UploadMethod', '이미지 업로드시 서버에 업로드 할지, 서버에 업로드 하지않고 이미지 태그 src에 base64로 추가할지 설정'],
            ['UploadImageFileObject', '붙여넣기 또는 드래그앤 드랍으로 이미지 삽입 시 file object로 업로드 할지 설정'],
            ['XssAllowUrl', 'XSS 방지하지 않을(허용할) url을 설정'],
            ['XssCheckAttribute', '에디터의 XSS 방지시 체크할 속성 항목들을 설정'],
            ['ZoomList', '우측 하단의 확대/축소 설정 콤보박스에 표시할 비율을 설정']
        ],
        [
            ['DEXT5Editor', '생성'],
            ['getEditor', '생성된 에디터 리턴'],
            ['setEditor', '다중 에디터 사용 시 접근할 에디터 설정'],
            ['getUserRuntimeMode', 'Runtime Mode 리턴'],
            ['getDext5Dom', '디자인 영역의 documentElement Dom 리턴'],
            ['getDext5BodyDom', '디자인 영역의 Body Dom 리턴'],
            ['setHtmlContents', 'set 되는 소스에 따라서 에디터 형태에 맞게 다시 set'],
            ['setHtmlContentsEw', '에디터 생성 전에 호출 하여도 set하려는 소스를 별도로 가지고 있다가 에디터가 생성 완료되면 자동으로 set'],
            ['getHtmlValueExWithDocType', '에디터 디자인 영역의 HTML 소스를 리턴', '에디터 디자인 영역의 <DOCTYPE> 태그 포함된 HTML 소스를 리턴'],
            ['setHtmlValueExWithDocType', '에디터 디자인 영역에 HTML 소스를 입력', '에디터 디자인 영역에 <DOCTYPE> 태그 포함된 HTML 소스를 입력'],
            ['getHtmlValueEx', '에디터 디자인 영역의 HTML 소스에서 <html> 부터 </html>까지의 소스를 리턴'],
            ['setHtmlValueEx', '에디터 디자인 영역에 <html> 부터 </html>까지의 소스를 입력'],
            ['getHtmlValue', '에디터 디자인 영역의 HTML 소스에서 <html> 태그 내부의 소스를 리턴'],
            ['setHtmlValue', '에디터 디자인 영역에 <html> 태그 내부의 소스를 입력'],
            ['getBodyValueEx', '에디터 디자인 영역의 HTML 소스에서 <body> 부터 </body>까지의 소스를 리턴'],
            ['setBodyValueEx', '에디터 디자인 영역에 <body> 부터 </body>까지의 소스를 입력'],
            ['getBodyValueExLikeDiv', '에디터 디자인 영역의 HTML 소스에서 <body> 부터 </body>까지의 소스를 div태그로 리턴'],
            ['setBodyValueExLikeDiv', 'div 태그를 에디터 디자인 영역에 <body> 태그로 입력'],
            ['getBodyValue', '에디터 디자인 영역의 HTML 소스에서 <body> 태그 내부의 소스를 리턴'],
            ['setBodyValue', '에디터 디자인 영역에 <body> 태그 내부의 소스를 입력'],
            ['getBodyTextValue', '에디터 디자인 영역의 HTML 소스에서 <body> 태그 내부의 텍스트만 리턴'],
            ['setInsertHTML', '에디터 디자인 영역에서 커서가 있는 위치에 html 소스를 삽입'],
            ['setInsertHTMLEx', '에디터 디자인 영역에서 커서가 있는 위치 혹은 작성영역 제일 뒤에 html 소스를 삽입'],
            ['setInsertText', '에디터 디자인 영역에서 커서가 있는 위치에 text를 삽입'],
            ['loadHtmlValueExFromURL', '에디터 디자인 영역에 지정한 경로의 html 페이지를 띄움'],
            ['getImages', '에디터 디자인 영역에 있는 이미지 태그의 경로를 리턴'],
            ['getImagesEx', '에디터 디자인 영역에 있는 이미지 태그 경로와 body,table,cell의 background 경로 리턴'],
            ['getContentsUrl', '에디터 디자인 영역에 있는 모든 객체의 경로 리턴', '에디터 디자인 영역에 있는 이미지, 영상, 파일 등의 경로 리턴'],
            ['getServerImages', '에디터 디자인 영역에 있는 서버 이미지 태그 경로 리턴'],
            ['getDeletedImageUrl', '에디터에서 삭제한 이미지의 url 리턴'],
            ['getDeletedElementsUrl', '에디터에서 삭제한 elements의 url 리턴'],
            ['addUserCssUrl', '에디터에 사용자의 css를 적용'],
            ['clearUserCssUrl', '에디터에 적용된 css 경로를 제거'],
            ['setUserCssText', '에디터에 사용자의 css를 style tag로 적용'],
            ['clearUserCssText', '에디터에 적용되어 있는 style tag를 삭제'],
            ['getToSavePathUrl', '에디터에 설정된 ToSavePathUrl 값 리턴', '에디터에 설정된 서버에 연결 된 저장소의 URL 경로 값 리턴'],
            ['setToSavePathUrl', '에디터의 ToSavePathUrl 값을 설정', '에디터의 서버에 연결 된 저장소의 URL 경로 값을 설정'],
            ['setSize', '에디터 로드 후 에디터의 크기 설정'],
            ['setFocusToEditor', '에디터가 로드 된 후 지정한 에디터에 포커스를 노출'],
            ['setNextTabElementId', '포커스를 줄 객체 아이디를 설정 하고 tab키를 입력하면 마지막 포커스가 설정한 아이디로 이동'],
            ['setRulerPosition', '에디터 가로 눈금자 포인터의 위치 값을 설정'],
            ['setEditorBodyEditable', '에디터 body 영역 안에 작성 가능 여부를 설정'],
            ['setFullScreen', '에디터를 전체화면으로 설정'],
            ['isEmpty', '에디터 디자인 영역에 내용이 있는지 없는지를 체크'],
            ['isDirty', '에디터 내용이 변경 되었는지 확인 할 수 있는 설정'],
            ['setDirty', '에디터를 로드 후 현재 에디터에 작성중인 문서를 변경 되지 않은 초기 문서로 설정'],
            ['loadAutoSaveHtml', '에디터 localstorage에 들어간 마지막 저장 내용 리턴'],
            ['getAccessibility', '에디터에 설정된 웹 접근성 단계 리턴'],
            ['setAccessibility', '에디터의 웹 접근성 단계를 설정'],
            ['getAccessibilityValidation', '에디터에 작성된 항목 중 웹 접근성 검증 시 위반 여부를 확인'],
            ['setAccessibilityValidation', '웹 접근성 검증 시 위반 항목이 있으면 웹 접근성 검증 팝업 창에 위반 목록을 노출'],
            ['setEditorMode', '에디터를 view 또는 edit 모드로 변경'],
            ['setEditorBorder', '에디터 전체 영역을 감싸고 있는 Border의 노출 여부를 설정'],
            ['selectAll', '에디터 디자인 영역에서 작성 된 모든 내용을 선택'],
            ['show', '에디터를 화면에 표시'],
            ['hidden', '에디터를 화면에서 숨김'],
            ['showTopMenu', '에디터의 메뉴 바를 표시하거나 숨기는 기능을 설정'],
            ['showToolbar', '에디터의 툴바를 표시하거나 숨기는 기능을 설정'],
            ['showStatusbar', '상태 바를 표시하거나 숨기는 기능을 설정'],
            ['setEditorChangeMode', '상태바의 탭을 이동하는 기능을 설정'],
            ['dext5EncodeMime', '에디터에서 작성된 html을 MIME 형태로 인코딩'],
            ['dext5EncodeMimeEx', '에디터에서 작성된 html을 MIME 형태로 인코딩'],
            ['dext5DecodeMime', 'mimeData를 decode'],
            ['doSaveHTML', '에디터에 작성한 소스를 html파일로 저장'],
            ['doPrint', '에디터에 작성한 소스를 프린트 '],
            ['doPrintPreview', '에디터에 작성한 소스를 프린트 미리보기 한 후 프린트'],
            ['addFormData', '에디터의 네트워크 요청들에 key, value로 된 formdata 항목을 추가'],
            ['addHtmlToSetValue', '에디터에 set 하는 API를 사용할때 내용의 앞 또는 뒤에 파라미터의 html 소스를 추가'],
            ['[PL]addHttpHeaderEx', '에디터에서 이미지 업로드 시 요청 헤더에 headerName, headerValue인 헤더를 추가'],
            ['addUserD5Event', '에디터 작성영역에 해당 id를 가진 element가 있으면 이벤트를 추가'],
            ['addUserJsUrl', '에디터 편집영역 iframe document의 head 영역에 해당 url의 js 파일을 추가'],
            ['addWebFontCssUrl', '에디터 편집영역 iframe document의 head 영역에 해당 url의 css 파일을 추가', '폰트 콤보박스 영역에 CSS파일 추가'],
            ['appendTableRow', '에디터 작성영역에 해당 id를 가진 table이 있으면 행을 추가'],
            ['changeImageData', '에디터 body영역에서 선택되어있는 image element를 파라미터의 image element로 변경'],
            ['cleanNestedHtml', '에디터에 작성 된 태그들 중 p태그만 중복태그 검사'],
            ['cleanNestedHtmlEx', ' 에디터에 작성 된 태그 중 중복 태그를 검사할 태그를 파라미터로 받아 중복태그를 검사'],
            ['cleanNestedHtmlForNode', '중복 검사할 node에서 중복 태그를 검사할 태그를 파라미터로 받아 중복태그를 검사'],
            ['cleanNestedTag', '중복 검사할 html이나 node를 파라미터로 보내고, 중복 태그 검사가 필요한 경우 confirmMessage 를 띄운 후 수락 시 중복 검사'],
            ['clearUserJsUrl', 'addUserJsUrl로 추가된 script를 모두 제거'],
            ['closeDialogPopup', '열려있는 dialog popup을 닫음'],
            ['contentsSizeCheck', 'maxContentsSize 파라미터에 입력한 값과 에디터 내의 Contents 전체 파일의 용량을 비교'],
            ['convertHtmlToText', 'html을 text로 변환 후 p태그로 감싼 값을 반환'],
            ['convertHWPFilter', 'html 소스를 hwp(한글파일)포맷으로 변경하여 반환'],
            ['convertMMToPxUnit', '태그 안의 width와 height 중 mm단위가 존재하면 px단위로 변경하여 반환'],
            ['createHyperLink', '에디터 body 현재 선택영역에 하이퍼링크를 추가'],
            ['deleteDynamicTable', 'dynamic table 지정 해제', '선택한 table의 class가 DEXT_fiVe_EdiTor_DynGird이면 클래스를 ""(공백)으로 설정'],
            ['destroy', '해당 id의 에디터를 제거'],
            ['dextCommands', 'command 파라미터에 해당하는 id의 팝업창을 활성화'],
            ['[PL]doSaveHTMLEx', 'html 파일로 저장하기를 수행'],
            ['editorPrint', '에디터의 내용으로 프린트 작업을 수행'],
            ['findWord', '에디터 body영역에서 문자열을 찾아 해당 영역을 select'],
            ['getBodyLineCount', '에디터 작성영역에 작성된 줄 수를 반환'],
            ['getBodyTextLength', '에디터 작성역에 작성된 글자수를 반환'],
            ['getByteLength', '파라미터 문자열의 Bytes 값을 반환'],
            ['getCaretElement', '에디터의 작성영역 현재 커서위치에 해당하는 element를 반환'],
            ['getCaretElementEx', '에디터의 작성영역 현재 커서위치에 해당하는 정확한 현재 element를 반환'],
            ['getCaretObject', '에디터의 작성영역 현재 커서위치에 해당하는 elements Node를 반환'],
            ['getD5Dom', '에디터 작성영역의 dom 정보가 담긴 object를 반환'],
            ['getDext5DocumentDom', '에디터의 document 객체를 반환'],
            ['getEditorByName', '에디터의 정보가 담긴 Object를 반환'],
            ['getEditorSize', '에디터의 사이즈 정보가 담긴 Object를 반환'],
            ['getEditorStyle', '파라미터로 넘겨준 element의 스타일 정보를 반환'],
            ['getElementById', '에디터 body의 파라미터 id값에 해당하는 html태그 element를 반환'],
            ['getElementsByName', '에디터의 body 내부의 html 소스 중 파라미터의 name와 동일한 name를 가진 태그들을 NodeList형태로 반환'],
            ['getElementsByTagName', '에디터의 body 내부의 html 소스 중 파라미터의 태그명와 동일한 태그명을 가진 태그들을 HtmlCollection 형태로 반환'],
            ['getFileSize', '파일경로를 배열로 받아 해당 배열 경로들의 총 파일 크기를 callBackFunc의 첫번째 파라미터로 반환'],
            ['getFileSizeEx', '파일경로를 배열로 받아 해당 배열 경로들의 각 파일 크기를 콤마(,)로 구분한 String값으로 callBackFunc의 첫번째 파라미터로 반환'],
            ['getForbiddenWordValidation', '에디터의 작성영역에 금지어가 존재하는지 여부를 확인'],
            ['getMetaTag', 'setMetaTag API로 설정한 meta 태그중 metaName 파라미터의 name을 가진 meta 태그의 content 부분을 반환'],
            ['getMultiValue', 'saveCurrValueInMultiValue API로 저장된 MultiValue를 반환'],
            ['getMultiValueLength', 'saveCurrValueInMultiValue API로 저장된 MultiValue의 수를 반환'],
            ['getPersonalDataValidation', '에디터의 작성영역에 개인정보(주민등록번호, 이메일, 전화번호)가 존재하는지를 확인'],
            ['[PL]getPluginVersion', '에디터의 플러그인 버전정보를 확인'],
            ['getSelectedCell', '에디터의 작성영역에 존재하는 표의 선택된 부분의 셀들을 배열에 담아서 반환'],
            ['getSelectedContent', '에디터의 작성영역에 선택된 부분의 text와 html을 오브젝트로 반환'],
            ['getValueInTextMode', '에디터에 작성한 내용을 text mode 값으로 반환받고 editor mode를 text로 변경'],
            ['getVisibility', '에디터의 visibility 설정값 확인'],
            ['setVisibility', '에디터의 visibility 설정값 설정'],
            ['inImage', '에디터 작성영역의 선택된 부분에 해당 src의 image를 삽입'],
            ['inputButton', '에디터에 버튼 dialog를 팝업'],
            ['inputCheckbox', '에디터에 체크박스 dialog를 팝업'],
            ['inputHiddenfield', '에디터에 숨김필드 dialog를 팝업'],
            ['inputImagebutton', '에디터에 이미지버튼 dialog를 팝업'],
            ['inputRadio', '에디터에 라디오버튼 dialog를 팝업'],
            ['inputSelect', '에디터에 펼침목록 dialog를 팝업'],
            ['inputTextarea', '에디터에 입력영역 dialog를 팝업'],
            ['inputTextfield', '에디터에 입력필드 dialog를 팝업'],
            ['insertDiv', '에디터 선택영역에 attributesObj의 정보로 div를 생성하여 삽입', 'divObj의 오브젝트가 에디터의 body에 존재하면 해당 div를 attributesObj의 정보로 변경'],
            ['insertDynamicTable', '에디터 작성영역에 선택한 테이블을 DynamicTable로 지정'],
            ['insertImg', '에디터 선택영역에 attributesObj의 정보로 image 객체를 생성하여 삽입', 'imgObj의 오브젝트가 에디터의 body에 존재하면 해당 image 객체를 attributesObj의 정보로 변경'],
            ['insertInput', '에디터 선택영역에 attributesObj의 정보로 input 객체를 생성하여 삽입', 'inputObj 오브젝트가 에디터의 body에 존재하면 해당 input 객체를 attributesObj의 정보로 변경'],
            ['insertSelect', '에디터 선택영역에 attributesObj의 정보로 select 객체를 생성하여 삽입', 'selectObj 오브젝트가 에디터의 body에 존재하면 해당 select 객체를 attributesObj의 정보로 변경'],
            ['insertTextarea', '에디터 선택영역에 attributesObj의 정보로 textarea 객체를 생성하여 삽입', 'textareaObj 오브젝트가 에디터의 body에 존재하면 해당 textarea 객체를 attributesObj의 정보로 변경'],
            ['isEmptyToString', '에디터에 작성한 내용의 유무를 확인'],
            ['[PL]isInstallSucceed', 'ieplugin이 설치되어있는지의 여부를 확인'],
            ['isLoadedEditorEx', '에디터의 load가 완료되었는지 확인', 'editorContentArea와 IsEditorLoadedHashTable 값을 2중으로 확인'],
            ['[PL]isPluginInstalled', 'ieplugin이 설치되어있는지의 여부를 확인'],
            ['loadHtmlValueExFromServerURL', '에디터의 body 영역에 서버url에 존재하는 html 파일을 붙여넣음'],
            ['manuallyTempSave', '에디터의 임시저장을 수행'],
            ['removeClassStyle', '에디터 작성영역의 셀렉션한 부분이 span Tag이고, 해당 className 이면 span 태그를 삭제'],
            ['removeCss', '에디터 셀렉션한 부분의 css 적용(class, style)을 제거'],
            ['removeNode', '에디터 작성영역에서 파라미터에 해당하는 node를 제거'],
            ['replaceBlocktoBr', 'html 소스의 p 태그를 삭제 후 br 태그로 변경한 후 반환'],
            ['replaceText', '셀렉션이 되어있지 않으면 파라미터(searchText) 값을 에디터 body에서 찾아서 selection', '셀렉션이 되어있고 그 값이 파라미터(searchText) 값 이면 파라미터(replace) 값으로 변경'],
            ['replaceTextAll', '에디터 작성영역의 모든 파라미터(searchText) 값을 파라미터(replaceText)값으로 변경'],
            ['saveCurrValueInMultiValue', '에디터에 작성한 내용을 MultiValue항목으로 키값을 부여하여 저장'],
            ['setAdjustTableBorderStyle', '테이블의 선이 보이지 않는 현상이 있을 때 bordercollapse를 임시로 바꿔주고 원상복원'],
            ['setCaretBeforeOrAfter', '에디터 작성영역에서 특정 노드를 앞/뒤 쪽에 커서를 위치하도록 동작'],
            ['setClassStyle', '에디터 작성영역의 selection을 <span class=className>태그로 감쌈'],
            ['setCustomDisableIconList', '에디터의 아이콘을 활성화/비활성화'],
            ['setDext5DomMode', '에디터의 현재 모드가 html 이거나 text 이면 design 모드로 설정'],
            ['setDirectEditHtmlUrl', '에디터 작성영역 body에 url의 html을 iframe으로 삽입'],
            ['setEditorBodyWidth', '에디터 작성영역 body의 width 값 및 ruler의 가이드라인 위치를 변경'],
            ['setElementInnerHTML', '에디터 body영역 안의 해당 id를 가진 element의 innerHtml을 파라미터의 strHtml로 변경'],
            ['setElementInnerText', '에디터 body영역 안의 해당 id를 가진 element의 innerText를 파라미터의 strHtml로 변경'],
            ['setFocusToObject', '에디터 body영역 안의 오브젝트에 focus 설정'],
            ['setFontBgColor', '에디터 body영역 안의 select된 부분의 배경색을 해당 색상으로 변경'],
            ['setFontColor', '에디터 body영역 안의 select된 부분의 폰트색상을 해당 색상으로 변경'],
            ['setFontFamily', '에디터 body영역 안의 select된 부분의 폰트스타일을 해당 폰트명으로 변경'],
            ['setFontFormat', '에디터 body영역 안의 select된 부분의 서식을 파라미터의 서식으로 적용/해제'],
            ['setFontSize', '에디터 body영역 안의 select된 부분의 폰트사이즈를 파라미터로준 폰트사이즈로 변경'],
            ['setForbiddenWordValidation', '금지어추출 다이얼로그를 팝업'],
            ['setFormDataTextValue', '에디터 body영역 안의 해당 name을 가진 태그의 value 값을 strText로 변경'],
            ['setHeightForDisplay', '에디터의 작성한 내용보다 에디터의 높이가 짧으면(스크롤이 있고, 잘린내용이 있으면) 한번에 볼수있도록 크기를 맞춰서 조정'],
            ['setHighlight', '에디터 작성영역의 파라미터(searchText)를 전부 찾아서 옵션 값에 따라 highlight를 적용 또는 해제'],
            ['setInsertHTMLToObject', '에디터 내부의 body 영역에 해당 objectID를 ID로 가진 element의 내부에 삽입하여 교체'],
            ['setLockCommand', '특정 액션(cmd)이 실행되지 않도록 설정'],
            ['setMetaTag', '에디터 document의 head 영역에 해당 name과 content로 meta tag를 생성하여 추가'],
            ['setNextValueInMultiValue', '에디터의 작성영역을 해당 key값으로 저장된 MultiValue의 값으로 변경'],
            ['setOriginalHtmlValue', '에디터 작성영역의 내용을 파라미터의 html value로 교체'],
            ['setPersonalDataValidation', '개인정보추출 검사 Dialog를 팝업'],
            ['setReadOnly', '에디터를 읽기 전용으로 설정'],
            ['setTableEdgeReduce', '에디터 디자인영역의 모든 표에 대해 표,셀 테두리 분리를 설정'],
            ['[PL]setTempRootDirectory', 'TempRootDirectory를 해당 경로로 지정'],
            ['setUserFontFamily', '에디터의 기본 폰트스타일 및 에디터에 작성된 전체영역의 폰트스타일을 해당 font로 변경'],
            ['setUserFontSize', '에디터의 기본 폰트사이즈 및 에디터에 작성된 폰트사이즈를 해당 사이즈로 변경'],
            ['setUserJsText', '에디터 편집영역 document의 head 부분에 user의 js 스크립트문을 추가'],
            ['clearUserJsText', 'addUserJsText로 추가된 script를 모두 제거'],
            ['setValueInTextMode', '에디터를 text 모드로 바꾸고 작성영역의 텍스트값을 textValue로 교체'],
            ['setZoom', '에디터 body영역을 해당 비율(%)만큼 확대 또는 축소']
        ],
        [
            ['AfterChangeMode', '에디터 보기화면 변경 후 이벤트가 발생', 'statusBar 변경 후 이벤트가 발생'],
            ['BeforeInsertUrl', '에디터에 파일 업로드 후 url 삽입 전에 발생'],
            ['BeforePaste', '에디터에 붙여넣기 전 이벤트가 발생'],
            ['CustomAction', '에디터에 custom icon을 추가하였을 때 icon 클릭 시 동작하는 메소드 '],
            ['EditorLoaded', '에디터가 로드 완료 되었을 때 발생', '에디터가 작업준비 되었을 때 발생'],
            ['FullScreen', '에디터 화면전환 시 발생', '에디터 전체화면, 기본화면 변환 시 발생'],
            ['LanguageDefinition', '에디터 생성 시 이벤트가 발생', '에디터에서 노출되는 아이콘명, 메세지 등을 변경'],
            ['OnError', '에러가 발생할 경우 발생'],
            ['Resized', '에디터 높이 리사이즈 완료 시 발생'],
            ['[AD]EditorImg', '관리자모드에서 img태그로 추가된 객체 더블클릭 시 이벤트가 발생'],
            ['[AD]EditorInput', '관리자모드에서 input태그로 추가된 객체를 더블클릭 시 이벤트가 발생'],
            ['[AD]EditorSelect', '관리자모드에서 select태그로 추가된 객체를 더블클릭 시 이벤트가 발생'],
            ['[AD]EditorTextarea', '관리자모드에서 textarea태그로 추가된 객체를 더블클릭 시 이벤트가 발생'],
            ['PasteImage', '에디터 이미지를 붙여넣기 한 후 이벤트가 발생'],
            ['MouseEvent', '에디터 body에서 모든 마우스 동작시 이벤트가 발생'],
            ['FocusEvent', '에디터 body의 focus를 잃으면 발생'],
            ['SetInsertComplete', '에디터의 setInsert API 사용 후 발생'],
            ['SetComplete', '에디터의 set API 사용 후 발생'],
            ['KeyEvent', '에디터 body에서 모든 키보드 동작시 이벤트가 발생'],
            ['AfterPopupShow', '에디터의 모든 팝업시 이벤트가 발생'],
            ['DialogLoaded', '에디터의 dialog가 Open되었을 때 발생'],
            ['DragEvent', '에디터 외부에서 body에 파일이나 이미지를 내려놓으면 발생', '에디터 contents(하이퍼링크, 이미지, 작성글) 등을 내부에서 드래그 하여 옮길 시 이벤트가 발생'],
            ['CommandEvent', '에디터의 command(각종기능) 실행 및 종료시 이벤트가 발생'],
            ['ContentsizeChange', '에디터에 content를 추가하거나 제거하여 총 size 합의 값이 변경되면 발생'],
            ['SetForbiddenWordComplete', '금지어 추출 다이얼로그가 적용, 취소, 닫기 등으로 완료 시 발생'],
            ['[PL]BeforeOpenHtmlConvert', '플러그인 모드 에디터에서 파일열기 수행 전 이벤트가 발생'],
            ['InputEvent', '에디터 body에 conetent를 붙여넣기 하면 발생', ' 키보드 입력으로 텍스트를 입력하거나 에디터 body의 작성내용이 지워질 때마다 발생']
        ]
    ],
    [
        ['기본 에디터 생성'],
        ['동적 에디터 생성'],
        ['다중 에디터'],
        ['특정위치에 내용삽입'],
        ['Css Url 추가'],
        ['Html Url 불러오기'],
        ['UI 컨트롤'],
        ['포커스 제어'],
        ['사용자 이미지 처리'],
        ['에디터 객체 컨트롤'],
        ['웹 접근성 검증'],
        ['DOM 관리'],
        ['숨겨진 영역에서 생성'],
        ['에디터 서명 삽입'],
        ['해상도별 보기 페이지']
    ]
];

function fnMenuSetting(bThridMenu, bSearchMenuClick) {
    if (bSearchMenuClick) {
        document.getElementById("search_word").value = "";
        document.getElementById('search_list').innerHTML = "";
        document.getElementById("search_list").style.display = "none";
    }

    var arrSelectedMenu = strSelectedMenu.split(',');
    var arrMenu = [];
    var strSelectedContentsUrl = '';

    var arrSelectedMenuLength = arrSelectedMenu.length;

    var arrMenuStatus = strMenuStatus.split(',');
    var arrMenuStatusLength = arrMenuStatus.length;

    if (arrSelectedMenuLength == 1 && (strMenuStatus == arrSelectedMenu[0] || (arrMenuStatusLength == 2 && arrMenuStatus[0] == arrSelectedMenu[0]))) {
        strMenuStatus = '';
    } else if (!bThridMenu && arrSelectedMenuLength == 2 && strMenuStatus == arrSelectedMenu[0] + ',' + arrSelectedMenu[1]) {
        strMenuStatus = arrSelectedMenu[0];
    } else {
        if (bThridMenu) {
            if (arrSelectedMenuLength == 2) {
                strMenuStatus = arrSelectedMenu[0];
            } else if (arrSelectedMenuLength == 3) {
                strMenuStatus = arrSelectedMenu[0] + ',' + arrSelectedMenu[1];
            }
        } else {
            strMenuStatus = strSelectedMenu;
        }
    }

    var arrFirstMenuLength = arrFirstMenu.length;

    for (var i = 0; i < arrFirstMenuLength; i++) {
        var arrSpFirstMenu = arrFirstMenu[i].split(G_vertical);
        var strFirstMenu = fnGetMenuText(arrSpFirstMenu[0], arrSpFirstMenu[1], arrSpFirstMenu[2]);

        if (((!bThridMenu && strMenuStatus.indexOf(i.toString()) == 0) || bThridMenu) && arrSelectedMenu[0] == i.toString()) {
            arrMenu[arrMenu.length] = '<li><a href="javascript:strSelectedMenu=\'' + i + '\';fnMenuSetting(false, false);" class="depth1"><i class="icon open"></i>' + strFirstMenu + '</a>';
        } else {
            arrMenu[arrMenu.length] = '<li><a href="javascript:strSelectedMenu=\'' + i + '\';fnMenuSetting(false, false);" class="depth1"><i class="icon close"></i>' + strFirstMenu + '</a>';
        }
        
        if (((!bThridMenu && strMenuStatus.indexOf(i.toString()) == 0) || bThridMenu) && arrSelectedMenu[0] == i.toString()) {
            var arrSecondMenuLength = arrSecondMenu[i].length;

            arrMenu[arrMenu.length] = '<ul>';

            for (var j = 0; j < arrSecondMenuLength; j++) {
                var arrSpSecondMenu = arrSecondMenu[i][j].split(G_vertical);
                var strSecondMenu = fnGetMenuText(arrSpSecondMenu[0], arrSpSecondMenu[1], arrSpSecondMenu[2]);
                var strFnMenuSetting = '';

                if (arrSpSecondMenu.length == 4) {
                    strFnMenuSetting = 'fnMenuSetting(true, false);';
                } else {
                    strFnMenuSetting = 'fnMenuSetting(false, false);';
                }

                arrMenu[arrMenu.length] = '<li><a href="javascript:strSelectedMenu=\'' + i + ',' + j + '\';' + strFnMenuSetting + '" class="depth2';
                if (((!bThridMenu && strMenuStatus.indexOf(i.toString() + ',' + j.toString()) == 0) || bThridMenu) && arrSelectedMenu[1] == j.toString()) {
                    if (arrSpSecondMenu.length == 4) {
                        arrMenu[arrMenu.length] = ' on"><i class="icon none"></i>';
                        strSelectedContentsUrl = arrSpSecondMenu[3];
                    } else {
                        arrMenu[arrMenu.length] = '"><i class="icon open"></i>';
                    }
                } else {
                    if (arrSpSecondMenu.length == 4) {
                        arrMenu[arrMenu.length] = '"><i class="icon none"></i>';
                    } else {
                        arrMenu[arrMenu.length] = '"><i class="icon close"></i>';
                    }
                }
                arrMenu[arrMenu.length] = strSecondMenu + '</a></li>';
                
                if (((!bThridMenu && strMenuStatus.indexOf(i.toString() + ',' + j.toString()) == 0) || bThridMenu) && arrSelectedMenu[1] == j.toString()) {
                    if (!!arrThirdMenu[i][j]) {
                        var arrThirdMenuLength = arrThirdMenu[i][j].length;

                        arrMenu[arrMenu.length] = '<ul>';

                        for (var k = 0; k < arrThirdMenuLength; k++) {
                            var arrSpThirdMenu = arrThirdMenu[i][j][k].split(G_vertical);
                            var strThirdMenu = fnGetMenuText(arrSpThirdMenu[0], arrSpThirdMenu[1], arrSpThirdMenu[2]);

                            if (arrSelectedMenu[2] == k.toString()) {
                                arrMenu[arrMenu.length] = '<li><a href="javascript:strSelectedMenu=\'' + i + ',' + j + ',' + k + '\';fnMenuSetting(true, false);" class="depth3 on">' + strThirdMenu + '</a></li>';
                                strSelectedContentsUrl = arrSpThirdMenu[3];
                            } else {
                                arrMenu[arrMenu.length] = '<li><a href="javascript:strSelectedMenu=\'' + i + ',' + j + ',' + k + '\';fnMenuSetting(true, false);" class="depth3">' + strThirdMenu + '</a></li>';
                            }
                        }

                        arrMenu[arrMenu.length] = '</ul>';
                    }
                }
            }

            arrMenu[arrMenu.length] = '</ul>';
        }

        arrMenu[arrMenu.length] = '</li>';
    }

    strPreSelectedMenu = strSelectedMenu;

    document.getElementById('side_menu').innerHTML = arrMenu.join("");

    if (!!strSelectedContentsUrl && strSelectedContentsUrl != '')
        fnContentsSetting(strSelectedContentsUrl);
}

function fnGetMenuText(strIcon, strTitleFlag, strTitle) {

    var strMenuText = '';

    switch (strIcon) {
        case "1":
            strMenuText += '<i class="icon icon_intro"></i>';
            break;
        case "2":
            strMenuText += '<i class="icon icon_guide"></i>';
            break;
        case "3":
            strMenuText += '<i class="icon icon_sample"></i>';
            break;
        case "4":
            strMenuText += '<i class="icon icon_setting"></i>';
            break;
        case "5":
            strMenuText += '<i class="icon icon_brace"></i>';
            break;
        case "6":
            strMenuText += '<i class="icon icon_serverinfo"></i>';
            break;
        case "7":
            strMenuText += '<i class="icon icon_js"></i>';
            break;
        case "8":
            strMenuText += '<i class="icon icon_net"></i>';
            break;
        case "9":
            strMenuText += '<i class="icon icon_ja"></i>';
            break;
        default:
            break;
    }

    switch (strTitleFlag) {
        case "0":
            strMenuText += '<span>' + strTitle + '</span>';
            break;
        case "1":
            strMenuText += '<span title="' + strTitle + '">' + strTitle + '</span>';
            break;
        default:
            break;
    }

    return strMenuText;

}

function fnContentsSetting(strSelectedContentsUrl) {

    document.getElementById("contentsFrame").src = strSelectedContentsUrl;

}

function fnKeyPressEvent(e) {
    if (e.keyCode == 13) {
        fnSearch();
        return false;
    }
}

function fnSearch() {

    document.getElementById('search_list').innerHTML = "";
    document.getElementById("search_list").style.display = "none";

    var strSearchWord = document.getElementById("search_word");
    var strSearchWordValue = strSearchWord.value;

    if (strSearchWordValue == '') {
        alert("검색어를 입력해주세요.");
        return;
    }

    var arrSearchMenuList = [];

    var arrFirstMenuLength = arrSearchWordMenu.length;
    for (var i = 0; i < arrFirstMenuLength; i++) {
        var arrSecondMenuLength = arrSearchWordMenu[i].length;
        for (var j = 0; j < arrSecondMenuLength; j++) {
            var arrThirdMenuLength = arrSearchWordMenu[i][j].length;
            for (var k = 0; k < arrThirdMenuLength; k++) {
                var objSearchMenu = arrSearchWordMenu[i][j][k];
                if (typeof objSearchMenu === 'string') {
                    if (objSearchMenu.toLowerCase().indexOf(strSearchWordValue.toLowerCase()) > -1 && (arrSearchMenuList.length == 0 || arrSearchMenuList[arrSearchMenuList.length - 1] != i.toString() + "," + j.toString()))
                        arrSearchMenuList[arrSearchMenuList.length] = i.toString() + "," + j.toString();
                } else {
                    var arrSearchMenuLength = objSearchMenu.length;
                    for (var l = 0; l < arrSearchMenuLength; l++) {
                        if (objSearchMenu[l] == undefined) {
                            console.log(objSearchMenu);
                            console.log(l);
                        }
                        if (objSearchMenu[l].toLowerCase().indexOf(strSearchWordValue.toLowerCase()) > -1 && (arrSearchMenuList.length == 0 || arrSearchMenuList[arrSearchMenuList.length - 1] != i.toString() + "," + j.toString() + "," + k.toString()))
                            arrSearchMenuList[arrSearchMenuList.length] = i.toString() + "," + j.toString() + "," + k.toString();
                    }
                }
            }
        }
    }

    var arrSearchMenuListLength = arrSearchMenuList.length;
    if (arrSearchMenuListLength == 1) {
        strSelectedMenu = arrSearchMenuList[0];
        fnMenuSetting(true, false);
        strSearchWord.value = '';
    } else if (arrSearchMenuListLength > 1) {
        var arrSearchList = [];
        arrSearchList[arrSearchList.length] = '<ul>';

        for (var i = 0; i < arrSearchMenuListLength; i++) {
            var strSearchMenuText = '';
            var arrSpSearchMenuList = arrSearchMenuList[i].split(',');
            var arrSpSearchMenuListLength = arrSpSearchMenuList.length;
            if (arrSpSearchMenuListLength == 1) {
                strSearchMenuText += arrFirstMenu[parseInt(arrSpSearchMenuList[0], 10)].split(G_vertical)[2];
            } else if (arrSpSearchMenuListLength == 2) {
                strSearchMenuText += arrFirstMenu[parseInt(arrSpSearchMenuList[0], 10)].split(G_vertical)[2];
                strSearchMenuText += ' &gt; ' + arrSecondMenu[parseInt(arrSpSearchMenuList[0], 10)][parseInt(arrSpSearchMenuList[1], 10)].split(G_vertical)[2];
            } else if (arrSpSearchMenuListLength == 3) {
                strSearchMenuText += arrFirstMenu[parseInt(arrSpSearchMenuList[0], 10)].split(G_vertical)[2];
                strSearchMenuText += ' &gt; ' + arrSecondMenu[parseInt(arrSpSearchMenuList[0], 10)][parseInt(arrSpSearchMenuList[1], 10)].split(G_vertical)[2];
                strSearchMenuText += ' &gt; ' + arrThirdMenu[parseInt(arrSpSearchMenuList[0], 10)][parseInt(arrSpSearchMenuList[1], 10)][parseInt(arrSpSearchMenuList[2], 10)].split(G_vertical)[2];
            }

            arrSearchList[arrSearchList.length] = '<li title="' + strSearchMenuText + '"><a href="javascript:strSelectedMenu=\'' + arrSearchMenuList[i] + '\';fnMenuSetting(true, true);">' + strSearchMenuText + '</a></li>';
        }

        arrSearchList[arrSearchList.length] = '</ul>';

        document.getElementById('search_list').innerHTML = arrSearchList.join("");
        document.getElementById('search_list').style.display = "";
    } else if (arrSearchMenuListLength == 0) {
        alert("검색 결과가 존재하지 않습니다.");
        strSearchWord.focus();
    }

}

function fnIndex() {

    document.getElementById("search_word").value = "";
    document.getElementById('search_list').innerHTML = "";
    document.getElementById("search_list").style.display = "none";

    strSelectedMenu = '';
    fnMenuSetting(false, false);

    var fnIframeLoad = function () {
        var iIndexContentsRowCount = 0;
        var arrIndexContents = [];

        var arrFirstSearchWordMenuLength = arrSearchWordMenu.length;

        for (var i = 0; i < arrFirstSearchWordMenuLength; i++) {

            var arrSecondSearchWordMenuLength = arrSearchWordMenu[i].length;
            for (var j = 0; j < arrSecondSearchWordMenuLength; j++) {

                var arrThirdIndexContents = [];
                var arrThirdSearchWordMenuLength = arrSearchWordMenu[i][j].length;
                for (var k = 0; k < arrThirdSearchWordMenuLength; k++) {

                    if (typeof arrSearchWordMenu[i][j][k] === 'string') {
                        arrThirdIndexContents[arrThirdIndexContents.length] = '<td><a href="javascript:parent.strSelectedMenu=\'' + i + ',' + j + '\';parent.fnMenuSetting(true, false);" title="' + arrSearchWordMenu[i][j][k] + '">' + arrSearchWordMenu[i][j][k] + '</a></td>';
                    } else {
                        var arrFourthIndexContents = [];
                        var arrFourthSearchWordMenuLength = arrSearchWordMenu[i][j][k].length;
                        for (var l = 0; l < arrFourthSearchWordMenuLength; l++) {
                            arrFourthIndexContents[arrFourthIndexContents.length] = '<td><a href="javascript:parent.strSelectedMenu=\'' + i + ',' + j + ',' + k + '\';parent.fnMenuSetting(true, false);" title="' + arrSearchWordMenu[i][j][k][l] + '">' + arrSearchWordMenu[i][j][k][l] + '</a></td>';
                        }

                        if (arrFourthSearchWordMenuLength < 4) {
                            for (var m = 0; m < 4 - arrFourthSearchWordMenuLength; m++) {
                                arrFourthIndexContents[arrFourthIndexContents.length] = '<td></td>';
                            }
                        }

                        var strTitleText = '';
                        strTitleText += arrFirstMenu[i].split(G_vertical)[2];
                        strTitleText += ' &gt; ' + arrSecondMenu[i][j].split(G_vertical)[2];
                        strTitleText += ' &gt; ' + arrThirdMenu[i][j][k].split(G_vertical)[2];

                        iIndexContentsRowCount++;
                        if (iIndexContentsRowCount % 2 == 0) {
                            arrIndexContents[arrIndexContents.length] = '<tr class="tb_color">';
                        } else {
                            arrIndexContents[arrIndexContents.length] = '<tr>';
                        }
                        arrIndexContents[arrIndexContents.length] = '<th><a href="javascript:parent.strSelectedMenu=\'' + i + ',' + j + ',' + k + '\';parent.fnMenuSetting(true, false);" title="' + strTitleText + '">' + strTitleText + '</a></th>';
                        arrIndexContents[arrIndexContents.length] = arrFourthIndexContents.join("");
                        arrIndexContents[arrIndexContents.length] = '</tr>';
                    }

                }

                if (arrThirdIndexContents.length != 0) {
                    if (arrThirdSearchWordMenuLength < 4) {
                        for (var m = 0; m < 4 - arrThirdSearchWordMenuLength; m++) {
                            arrThirdIndexContents[arrThirdIndexContents.length] = '<td></td>';
                        }
                    }

                    var strTitleText = '';
                    strTitleText += arrFirstMenu[i].split(G_vertical)[2];
                    strTitleText += ' &gt; ' + arrSecondMenu[i][j].split(G_vertical)[2];

                    iIndexContentsRowCount++;
                    if (iIndexContentsRowCount % 2 == 0) {
                        arrIndexContents[arrIndexContents.length] = '<tr class="tb_color">';
                    } else {
                        arrIndexContents[arrIndexContents.length] = '<tr>';
                    }
                    arrIndexContents[arrIndexContents.length] = '<th><a href="javascript:parent.strSelectedMenu=\'' + i + ',' + j + '\';parent.fnMenuSetting(true, false);" title="' + strTitleText + '">' + strTitleText + '</a></th>';
                    arrIndexContents[arrIndexContents.length] = arrThirdIndexContents.join("");
                    arrIndexContents[arrIndexContents.length] = '</tr>';
                }

            }

        }

        document.all.contentsFrame.contentDocument.getElementById("index_contents").innerHTML = arrIndexContents.join("");
        removeEvent(objIframe, 'load', fnIframeLoad);
    }

    var objIframe = document.getElementById("contentsFrame");
    addEvent(objIframe, 'load', fnIframeLoad, false);
    objIframe.src = 'searchIndex.html';
    
}

function addEvent(element, event, func, useCapture) {
    if (element.addEventListener) { element.addEventListener(event, func, useCapture); } else if (element.attachEvent) { element.attachEvent('on' + event, func); }
}

function removeEvent(element, event, func, useCapture) {
    if (element.removeEventListener) { element.removeEventListener(event, func, useCapture); } else if (element.detachEvent) { element.detachEvent('on' + event, func); }
}