(function(){try{var D=function(){c.G_TABLE_TO_CHART_CURSOR=GetParentbyTagName(getFirstRange().range.startContainer,"table",!0);var b=w(),g=b.length,h=C(b);4>=b.length||b.length==h||b.length==b.length/h?alert(c.lang.message.not_enough_data):(c.G_TABLE_TO_CHART_ROW=g/h,c.G_TABLE_TO_CHART_COLUMN=h,c.G_TABLE_TO_CHART_DATA=b,DEXT5_EDITOR.prototype.dialog.show(_dext_editor._config.webPath.plugin,"chart/editor_popup.html"))},w=function(){var b=GetTableSelectionCells(DEXTTOP.G_SELECTED_ELEMENT,!0);if(1>b.length){var g,
b=[];g=navigator.userAgent.toLowerCase();if(-1<g.indexOf("chrome")||-1<g.indexOf("firefox")||-1<g.indexOf("safari")){g=ActiveCurrTable;for(var c=g.rows.length,f=0,a=0;a<c;a++)for(var n=g.firstElementChild.children[a].childElementCount,d=0;d<n;d++)b[f]=g.firstElementChild.children[a].childNodes[d],f++}else for(g=ActiveCurrTable.cells,c=0;c<g.length;c++)b[c]=g[c]}return b},E=function(){for(var b=w(),c=/colspan="[2-9][0-9]*"/,h=/rowspan="[2-9][0-9]*"/,f=0;f<b.length;f++)if(null!=b[f].outerHTML.match(c)||
null!=b[f].outerHTML.match(h))return!0;return!1},C=function(b){for(var c=v=x=0,h=0,f,a,n=0,d=0;d<b.length;d++)0==d?(f=b[d].cellIndex,a=b[d].cellIndex+b[d].colSpan-1,1<b[d].rowSpan&&x++,1<b[d].colSpan&&(v++,n=b[d].colSpan-1)):(a<b[d].cellIndex+b[d].colSpan-1+n&&(a=b[d].cellIndex+b[d].colSpan-1+n),f==b[d].cellIndex&&(n=0),1<b[d].rowSpan&&(x++,F.push({cellIndex:b[d].cellIndex,rangeIdx:d}),c++),1<b[d].colSpan&&(v++,G.push({cellIndex:b[d].cellIndex,rangeIdx:d}),h++));for(b=0;b<c;b++);for(b=0;b<h;b++);
return a-f+1},c={pluginName:"chart"};G_DEPlugin.chart=c;c.isSupportBrowser=!0;c.onShowTopMenu=function(b,g){if(!c.isSupportBrowser)return null;switch(b){case "m_insert":return g.push("p_chart"),g;case "m_table":return null;default:return null}};c.onResize=function(b){if("end"==b.cmd&&(void 0!=b.isResize||void 0!=b.target)&&c.isSupportBrowser){var g=b.isResize;b=b.target;g&&b&&"img"==b.nodeName.toLowerCase()&&b.getAttribute("raon_chart")?(g={element:b},c.G_TABLE_TO_CHART_CURSOR=null,c.insertChart(g)):
!g&&b.getAttribute("raon_chart")&&(g={element:b},c.G_TABLE_TO_CHART_CURSOR=null,c.insertChart(g))}};c.insertChart=function(b,g){var h=function(a){var b=a.split(",");4==b.length?(b[3]="0.7)",a=b.join()):(a=a.replace(/b/,"ba"),a=a.replace(/\)/,",0.7)"));return a},f=b.element,a=b.chart,n=b.preview;if(null!=f&&!a&&!n){var d=DEXTTOP.DEXT5.util.makeDecryptReponseMessage(f.getAttribute("raon_chart")),a=JSON.parse(d.replace(/&quot;/g,'"')).data;a.width=f.clientWidth;a.height=f.clientHeight}var d="line",t=
{},k={responsive:!1},z=!0,w=!1,r,m,p,A,v,y,x;yStack=xStack=!1;t.labels=[];for(var e=1;e<a.data.length;e++)t.labels.push(a.data[e][0]);e=a.type.split("-");d=e[0];e=e[1];switch(d){case "line":d="line";r=!1;m=a.color.column;if(2==e||4==e)y=0;if(3==e||4==e)x=0;break;case "bar":d=3==e||4==e?"horizontalBar":"bar";p=a.color.column;if(2==e||4==e)yStack=xStack=!0;break;case "area":d="line";p=a.color.column;r=!0;if(2==e||4==e)y=0;if(3==e||4==e)yStack=!0;break;case "circle":z=!1;1==e?d="pie":2==e&&(d="doughnut");
p=a.color.column;break;case "radar":5==e?(d="polarArea",z=!1,p=a.color.column,k.layout={padding:{top:5,bottom:5}}):(d="radar",1==e?A=p=m=a.color.column:2==e?(p=m=a.color.column,y=0):3==e?(m=a.color.column,r=!1,p=a.color.column,y=0):4==e&&(m=["rgba(0,0,0,0)"],r=!1,v=A=p=a.color.column));break;case "scatter":d=1==e?"scatter":"bubble",w=!0,p=a.color.column}t.datasets=[];var u=0;if(z)for(e=1;e<a.data[0].length;e++){var l={};if(w)if(l.label=a.data[0][e],p&&(l.backgroundColor=p[u]),l.data=[],"scatter"==
d)for(var q=1;q<a.data.length;q++)l.data.push({x:a.data[q][0],y:a.data[q][e]});else{if("bubble"==d){for(q=1;q<a.data.length;q++)l.data.push({x:a.data[q][0],y:a.data[q][e],r:a.data[q][e+1]});e++}}else{l.label=a.data[0][e];l.data=[];for(q=1;q<a.data.length;q++)l.data.push(a.data[q][e]);l.fill=r;l.pointRadius=y;l.lineTension=x;m&&(l.borderColor=m[u]?m[u]:m);p&&(l.backgroundColor=p[u]?h(p[u]):p);A&&(l.pointBorderColor=A[u]);v&&(l.pointBackgroundColor=h(v[u]))}t.datasets.push(l);u++}else{t.labels=a.data[0];
l={data:a.data[1],fill:r,pointRadius:y};m&&(l.borderColor=m);if(p)for(l.backgroundColor=[];u<a.data[0].length;)l.backgroundColor.push(h(p[u++]));t.datasets.push(l)}h=parseFloat(a.axes.max);r=parseFloat(a.axes.min);m=parseFloat(a.axes.step);if(z&&"radar"!=d)k.scales={xAxes:[{stacked:xStack,gridLines:{display:a.grid},scaleLabel:{display:0<a.axes.x.text.length,labelString:a.axes.x.text,fontFamily:a.axes.x.fontFamily,fontSize:a.axes.x.fontSize,fontStyle:a.axes.x.fontStyle,fontColor:a.axes.x.fontColor},
ticks:{}}],yAxes:[{stacked:yStack,gridLines:{display:a.grid},scaleLabel:{display:0<a.axes.y.text.length,labelString:a.axes.y.text,fontFamily:a.axes.y.fontFamily,fontSize:a.axes.y.fontSize,fontStyle:a.axes.y.fontStyle,fontColor:a.axes.y.fontColor},ticks:{}}]},"horizontalBar"==d?(""!=a.axes.max&&(k.scales.xAxes[0].ticks.max=h),""!=a.axes.min&&(k.scales.xAxes[0].ticks.min=r),""!=a.axes.step&&(k.scales.xAxes[0].ticks.stepSize=m)):"scatter"==d||"bubble"==d?(""!=a.axes.max&&(k.scales.xAxes[0].ticks.max=
h,k.scales.yAxes[0].ticks.max=h),""!=a.axes.min&&(k.scales.xAxes[0].ticks.min=r,k.scales.yAxes[0].ticks.min=r),""!=a.axes.step&&(k.scales.xAxes[0].ticks.stepSize=m,k.scales.yAxes[0].ticks.stepSize=m)):(""!=a.axes.max&&(k.scales.yAxes[0].ticks.max=h),""!=a.axes.min&&(k.scales.yAxes[0].ticks.min=r),""!=a.axes.step&&(k.scales.yAxes[0].ticks.stepSize=m));else if("radar"==d||"polarArea"==d)k.scale={ticks:{}},""!=a.axes.max&&(k.scale.ticks.max=h),""!=a.axes.min&&(k.scale.ticks.min=r),""!=a.axes.step&&(k.scale.ticks.stepSize=
m);k.title={display:0<a.title.text.length,position:a.title.position,text:a.title.text,fontFamily:a.title.fontFamily,fontSize:a.title.fontSize,fontStyle:a.title.fontStyle,fontColor:a.title.fontColor};k.legend={display:a.legend.display,position:a.legend.position,labels:{fontFamily:a.legend.fontFamily,fontSize:parseFloat(a.legend.fontSize),fontStyle:a.legend.fontStyle,fontColor:a.legend.fontColor}};canvas=document.createElement("canvas");a.width=0<parseIntOr0(a.width)?a.width:400;a.height=0<parseIntOr0(a.height)?
a.height:200;canvas.width=a.width;canvas.height=a.height;k.animation={duration:0,onComplete:function(b,d){var e=document.createElement("canvas");e.width=a.width;e.height=a.height;e.getContext("2d").fillStyle=a.color.background;e.getContext("2d").fillRect(this.chartArea.left,this.chartArea.top,this.chartArea.right-this.chartArea.left,this.chartArea.bottom-this.chartArea.top);e.getContext("2d").drawImage(this.canvas,0,0,e.width,e.height);var h=e.toDataURL();if(n)f.width=582<e.width?582:e.width,f.height=
320<e.height?320:e.height,f.src=h;else{if(f)hideDialog(g);else{f=_iframeDoc.createElement("img");e={pluginName:c.pluginName,action:"insert_image",image:f,closeDialog:!!g};if(c.G_TABLE_TO_CHART_CURSOR){var k=c.G_TABLE_TO_CHART_CURSOR;if(!k.nextSibling){var l=_iframeDoc.createElement("p");k.parentNode.appendChild(l)}var l=getFirstRange(),m=l.range;m.setStart(k.nextSibling,0);m.setEnd(k.nextSibling,0);l.sel.removeAllRanges();l.sel.addRange(m);_dext_editor._LastRange=m}event_dext5plugin_action(e,g)}f.src=
h;h=DEXTTOP.DEXT5.util.makeEncryptParam(JSON.stringify({data:a}));f.setAttribute("raon_chart",h);f.style.width=a.width+"px";f.style.height=a.height+"px"}}};new Chart(canvas,{type:d,data:t,options:k})};c.onClickToolIcon=function(b){if(c.isSupportBrowser)switch(c.G_TABLE_TO_CHART_DATA=null,c.G_TABLE_TO_CHART_COLUMN=null,c.G_TABLE_TO_CHART_ROW=null,c.G_TABLE_TO_CHART_CURSOR=null,b){case "chart":DEXTTOP.G_SELECTED_ELEMENT=null;DEXT5_EDITOR.prototype.dialog.show(_dext_editor._config.webPath.plugin,"chart/editor_popup.html");
break;case "tabletochart":c.tableToChart();case "chartproperty":DEXT5_EDITOR.prototype.dialog.show(_dext_editor._config.webPath.plugin,"chart/editor_popup.html")}};c.onDisableToolIcon=function(b){switch(b){case "":case "default":return["p_chart_tabletochart"];case "selectedMultiCell":return["p_chart"];case "focusInCell":return!1;default:return["p_chart","p_chart_tabletochart"]}};c.onCreateContextMenu=function(b){c.isSupportBrowser&&(b.items="paste cut copy  select_all  p_chart_chartproperty".split(" "),
b.disabledItems=["paste"],b.height="300px",b.width="200px")};c.onDbClickImage=function(b){c.isSupportBrowser&&(c.G_TABLE_TO_CHART_DATA=null,c.G_TABLE_TO_CHART_COLUMN=null,c.G_TABLE_TO_CHART_ROW=null,c.G_TABLE_TO_CHART_CURSOR=null,DEXT5_EDITOR.prototype.dialog.show(_dext_editor._config.webPath.plugin,"chart/editor_popup.html"))};c.onInit=function(){if(!DEXTTOP.DEXT5.browser.canvasSupported||DEXTTOP.DEXT5.browser.ie&&9>DEXTTOP.DEXT5.browser.ieVersion){c.isSupportBrowser=!1;var b=_dext_editor;b.remove_item.push("p_chart");
b.remove_item.push("p_chart_tabletochart")}else B("../plugin/chart/js"+(DEXTTOP.DEXT5.isRelease?"":"_dev")+"/chart.js?ver="+DEXTTOP.DEXT5.ReleaseVer),B("../plugin/chart/js"+(DEXTTOP.DEXT5.isRelease?"":"_dev")+"/grid.js?ver="+DEXTTOP.DEXT5.ReleaseVer),b="../plugin/chart/js"+(DEXTTOP.DEXT5.isRelease?"":"_dev")+"/config.js",b="1"==DEXTTOP.DEXT5.config.UseConfigTimeStamp?b+("?t="+DEXTTOP.DEXT5.util.getTimeStamp()):b+("?ver="+DEXTTOP.DEXT5.ReleaseVer),B(b)};var B=function(b){var c=document.getElementsByTagName("head")[0],
h=document.createElement("script");h.type="text/javascript";h.src=b;c.appendChild(h)};c.onInit();c.onLoaded=function(){c.isSupportBrowser&&(DEXT5_CONTEXT._item_sub_list.table_tool.push("p_chart_tabletochart"),DEXT5_TOPMENU._item_sub_list.table_tool.push("p_chart_tabletochart"))};var x=0,v=0,F=[],G=[];c.tableToChart=function(){restoreSelection();var b=w(),g,h,f=0;if(c.allowMergedTableToChart)if(h=C(b),4>=b.length||b.length==h||b.length==b.length/h)alert(c.lang.message.not_enough_data);else{g=b.length;
f=0;g=[];for(var a=0,n=0;b[f];){a=0;rowPos=parseInt(f/h);if(1<b[f].colSpan){for(a=2;a<=b[f].colSpan;a++)b.splice(f+a-1,0,"0");for(var a=0,d=2;d<=b[f].rowSpan;){for(var t=2;t<=b[f].colSpan;t++)g.push(f+n+((d-1)*h+t-1)),a++;g.push(f+n+(d-1)*h);a++;d++}n+=a}else if(1<b[f].rowSpan){for(d=2;d<=b[f].rowSpan;d++)g.push(f+n+h*(d-1)),a++;n+=a}f++}g=g.sort(function(a,b){return a-b});for(f=0;f<g.length;f++)b.splice(g[f],0,"0");g=b.length;g/=h;c.G_TABLE_TO_CHART_ROW=g;c.G_TABLE_TO_CHART_DATA=b;c.G_TABLE_TO_CHART_COLUMN=
h;g!==parseInt(g)?alert(c.lang.message.incorrect_selection):(c.G_TABLE_TO_CHART_CURSOR=GetParentbyTagName(getFirstRange().range.startContainer,"table",!0),DEXT5_EDITOR.prototype.dialog.show(_dext_editor._config.webPath.plugin,"chart/editor_popup.html"))}else E()?alert(c.lang.message.merge):D()}}catch(H){}})();
