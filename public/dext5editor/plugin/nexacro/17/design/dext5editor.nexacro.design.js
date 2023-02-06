//==============================================================================
//  RAONWIZ Co., Ltd.
//  Copyright 2018 RAONWIZ Co., Ltd.
//  All Rights Reserved.
//==============================================================================

if (nexacro.DEXT5Editor)
{
    var _pDEXT5Editor = nexacro.DEXT5Editor.prototype;
    
    _pDEXT5Editor.on_create_contents = function ()
    {
        var control_elem = this.getElement();
        if (control_elem)
        {
            var cellElem = new nexacro.TextBoxElement(control_elem, "icontext");
            this._cell_elem = cellElem;
            cellElem.setElementSize(control_elem.client_width, control_elem.client_height);
				
            cellElem.setElementTextAlign("center");
            cellElem.setElementVerticalAlign("middle");
            this.on_apply_text(this.name);

            this.set_border("1px solid #cccccc");
        }
    };

    _pDEXT5Editor.on_created_contents = function (win)
    {   
        var cellElem = this._cell_elem;
        if (cellElem)
        {
            cellElem.create(win);
        }
    };

    _pDEXT5Editor.on_destroy_contents = function ()
    {
        var cellElem = this._cell_elem;
        if (cellElem)
        {
            cellElem.destroy();
            this._cell_elem = null;
        }
    };
	
    _pDEXT5Editor.on_change_containerRect = function (width, height)
    {
        if (this._is_created_contents)
        {
            var cellElem = this._cell_elem;
            cellElem.setElementSize(width, height);
        }
    };

    _pDEXT5Editor.on_apply_text = function (text)
    {
        var cellElem = this._cell_elem;
        if (cellElem)
        {
            cellElem.setElementText(text);
        }
    };

    _pDEXT5Editor.createCssDesignContents = function ()
    {
        this.set_text("DEXT5Editor");
    };

    delete _pDEXT5Editor;
}

