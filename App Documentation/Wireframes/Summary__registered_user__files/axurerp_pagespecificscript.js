for(var i = 0; i < 790; i++) { var scriptId = 'u' + i; window[scriptId] = document.getElementById(scriptId); }

$axure.eventManager.pageLoad(
function (e) {

});

if (bIE) document.getElementById('u273').attachEvent("onmousedown", function(e) { StartDragWidget(e, 'u273'); });
else {
    document.getElementById('u273').addEventListener("mousedown", function(e) { StartDragWidget(e, 'u273'); }, true);
    document.getElementById('u273').addEventListener("touchstart", function(e) { StartDragWidget(e, 'u273'); }, true);
}

widgetIdToDragFunction['u273'] = function() {
var e = windowEvent;

if (true) {

	SetPanelStateNext('u273',false,'swing','down',500,'swing','down',500);

}

}

if (bIE) document.getElementById('u258').attachEvent("onmousedown", function(e) { StartDragWidget(e, 'u258'); });
else {
    document.getElementById('u258').addEventListener("mousedown", function(e) { StartDragWidget(e, 'u258'); }, true);
    document.getElementById('u258').addEventListener("touchstart", function(e) { StartDragWidget(e, 'u258'); }, true);
}

widgetIdToStartDragFunction['u258'] = function() {
var e = windowEvent;

if (((GetPanelState('u258')) == ('pd0u258')) || ((GetPanelState('u258')) == ('pd1u258'))) {

	SetPanelStateNext('u258',false,'swing','down',500,'swing','down',500);

}
else
if ((GetPanelState('u258')) == ('pd2u258')) {

	SetPanelState('u258', 'pd0u258','swing','down',500,'swing','down',500);

}

}

if (bIE) document.getElementById('u303').attachEvent("onmousedown", function(e) { StartDragWidget(e, 'u303'); });
else {
    document.getElementById('u303').addEventListener("mousedown", function(e) { StartDragWidget(e, 'u303'); }, true);
    document.getElementById('u303').addEventListener("touchstart", function(e) { StartDragWidget(e, 'u303'); }, true);
}

widgetIdToSwipeLeftFunction['u303'] = function() {
var e = windowEvent;

if ((GetPanelState('u303')) == ('pd0u303')) {

	SetPanelState('u303', 'pd1u303','swing','left',500,'swing','left',500);

}
else
if ((GetPanelState('u303')) == ('pd2u303')) {

	SetPanelState('u303', 'pd0u303','swing','left',500,'swing','left',500);

}

}

widgetIdToSwipeRightFunction['u303'] = function() {
var e = windowEvent;

if ((GetPanelState('u303')) == ('pd0u303')) {

	SetPanelState('u303', 'pd2u303','swing','right',500,'swing','right',500);

}
else
if ((GetPanelState('u303')) == ('pd1u303')) {

	SetPanelState('u303', 'pd0u303','swing','right',500,'swing','right',500);

}

}
gv_vAlignTable['u285'] = 'top';gv_vAlignTable['u691'] = 'top';gv_vAlignTable['u281'] = 'top';u213.tabIndex = 0;

u213.style.cursor = 'pointer';
$axure.eventManager.click('u213', function(e) {

if (true) {

	SetPanelVisibility('u614','','none',500);

}
});
gv_vAlignTable['u493'] = 'center';gv_vAlignTable['u400'] = 'center';u206.tabIndex = 0;

u206.style.cursor = 'pointer';
$axure.eventManager.click('u206', function(e) {

if (true) {

	SetPanelVisibility('u614','','none',500);

}
});
gv_vAlignTable['u263'] = 'top';u612.tabIndex = 0;

u612.style.cursor = 'pointer';
$axure.eventManager.click('u612', function(e) {

if (true) {

	SetPanelVisibility('u528','hidden','none',500);

}
});
gv_vAlignTable['u250'] = 'center';gv_vAlignTable['u637'] = 'center';document.getElementById('u234_img').tabIndex = 0;

u234.style.cursor = 'pointer';
$axure.eventManager.click('u234', function(e) {

if (true) {

	SetPanelVisibility('u216','hidden','none',500);

}
});
gv_vAlignTable['u453'] = 'center';gv_vAlignTable['u699'] = 'top';gv_vAlignTable['u202'] = 'center';gv_vAlignTable['u421'] = 'center';document.getElementById('u640_img').tabIndex = 0;

u640.style.cursor = 'pointer';
$axure.eventManager.click('u640', function(e) {

if ((GetPanelState('u643')) == ('pd0u643')) {

	SetPanelState('u643', 'pd4u643','none','',500,'none','',500);

}
else
if ((GetPanelState('u643')) == ('pd3u643')) {

	SetPanelState('u643', 'pd0u643','none','',500,'none','',500);

}
else
if (((GetPanelState('u643')) != ('pd0u643')) && ((GetPanelState('u643')) != ('pd3u643'))) {

	SetPanelStateNext('u643',false,'none','',500,'none','',500);

}
});
gv_vAlignTable['u665'] = 'center';gv_vAlignTable['u603'] = 'center';document.getElementById('u81_img').tabIndex = 0;

u81.style.cursor = 'pointer';
$axure.eventManager.click('u81', function(e) {

if (true) {

	SetPanelVisibility('u464','','none',500);

}
});
gv_vAlignTable['u262'] = 'top';document.getElementById('u230_img').tabIndex = 0;

u230.style.cursor = 'pointer';
$axure.eventManager.click('u230', function(e) {

if (true) {

	SetPanelVisibility('u216','hidden','none',500);

}
});
gv_vAlignTable['u601'] = 'center';gv_vAlignTable['u408'] = 'center';document.getElementById('u249_img').tabIndex = 0;

u249.style.cursor = 'pointer';
$axure.eventManager.click('u249', function(e) {

if (true) {

	SetPanelVisibility('u240','hidden','none',500);

}
});
gv_vAlignTable['u468'] = 'top';gv_vAlignTable['u396'] = 'top';gv_vAlignTable['u63'] = 'top';gv_vAlignTable['u470'] = 'center';gv_vAlignTable['u275'] = 'top';gv_vAlignTable['u22'] = 'center';gv_vAlignTable['u425'] = 'center';gv_vAlignTable['u98'] = 'center';
u113.style.cursor = 'pointer';
$axure.eventManager.click('u113', function(e) {

if (((GetCheckState('u103')) == (true)) || (((GetCheckState('u105')) == (true)) || (((GetCheckState('u107')) == (true)) || (((GetCheckState('u109')) == (true)) || (((GetCheckState('u111')) == (true)) || (((GetCheckState('u113')) == (true)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || ((GetCheckState('u121')) == (true))))))))))) {

	SetPanelVisibility('u475','','none',500);

}
else
if (((GetCheckState('u103')) == (false)) || (((GetCheckState('u105')) == (false)) || (((GetCheckState('u107')) == (false)) || (((GetCheckState('u109')) == (false)) || (((GetCheckState('u111')) == (false)) || (((GetCheckState('u113')) == (false)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || ((GetCheckState('u121')) == (true))))))))))) {

	SetPanelVisibility('u475','hidden','none',500);

}
});
gv_vAlignTable['u393'] = 'top';gv_vAlignTable['u300'] = 'center';gv_vAlignTable['u106'] = 'top';gv_vAlignTable['u325'] = 'top';u512.tabIndex = 0;

u512.style.cursor = 'pointer';
$axure.eventManager.click('u512', function(e) {

if (true) {

	SetPanelVisibility('u528','','none',500);

	SetPanelState('u528', 'pd0u528','none','',500,'none','',500);
function waitude3967ce88934c4d87ae6ed30c0aea281() {

	SetPanelState('u528', 'pd1u528','none','',500,'none','',500);
function waituac1872c232f44c829d71af3cc9b17b4e1() {

	SetPanelState('u528', 'pd2u528','none','',500,'none','',500);
}
setTimeout(waituac1872c232f44c829d71af3cc9b17b4e1, 3000);
}
setTimeout(waitude3967ce88934c4d87ae6ed30c0aea281, 3500);

}
});
gv_vAlignTable['u166'] = 'top';gv_vAlignTable['u134'] = 'top';gv_vAlignTable['u505'] = 'center';gv_vAlignTable['u599'] = 'center';gv_vAlignTable['u39'] = 'top';u346.tabIndex = 0;

u346.style.cursor = 'pointer';
$axure.eventManager.click('u346', function(e) {

if (true) {

	SetPanelState('u286', 'pd2u286','swing','down',500,'swing','down',500);

	SetPanelState('u303', 'pd3u303','none','',500,'none','',500);

}
});
gv_vAlignTable['u565'] = 'center';gv_vAlignTable['u128'] = 'top';gv_vAlignTable['u314'] = 'top';gv_vAlignTable['u533'] = 'top';gv_vAlignTable['u130'] = 'center';gv_vAlignTable['u501'] = 'center';u374.tabIndex = 0;

u374.style.cursor = 'pointer';
$axure.eventManager.click('u374', function(e) {

if (true) {

	SetPanelState('u286', 'pd3u286','swing','down',500,'swing','down',500);

	SetPanelState('u303', 'pd4u303','none','',500,'none','',500);

}
});
gv_vAlignTable['u745'] = 'top';gv_vAlignTable['u342'] = 'top';gv_vAlignTable['u368'] = 'center';document.getElementById('u95_img').tabIndex = 0;

u95.style.cursor = 'pointer';
$axure.eventManager.click('u95', function(e) {

if (true) {

	SetPanelVisibility('u464','','none',500);

}
});
gv_vAlignTable['u53'] = 'top';u370.tabIndex = 0;

u370.style.cursor = 'pointer';
$axure.eventManager.click('u370', function(e) {

if (true) {

	SetPanelState('u286', 'pd1u286','swing','down',500,'swing','down',500);

	SetPanelState('u303', 'pd5u303','none','',500,'none','',500);

}
});
gv_vAlignTable['u364'] = 'top';gv_vAlignTable['u548'] = 'top';u12.tabIndex = 0;

u12.style.cursor = 'pointer';
$axure.eventManager.click('u12', function(e) {

if (true) {

    self.location.href="resources/reload.html#" + encodeURI($axure.globalVariableProvider.getLinkUrl($axure.pageData.url));

}
});
gv_vAlignTable['u77'] = 'top';gv_vAlignTable['u491'] = 'top';gv_vAlignTable['u297'] = 'top';gv_vAlignTable['u265'] = 'top';gv_vAlignTable['u697'] = 'top';gv_vAlignTable['u293'] = 'top';gv_vAlignTable['u200'] = 'top';gv_vAlignTable['u225'] = 'top';gv_vAlignTable['u412'] = 'top';u437.tabIndex = 0;

u437.style.cursor = 'pointer';
$axure.eventManager.click('u437', function(e) {

if (true) {

	SetPanelState('u286', 'pd1u286','swing','down',500,'swing','down',500);

	SetPanelState('u303', 'pd5u303','none','',500,'none','',500);

}
});
gv_vAlignTable['u49'] = 'top';gv_vAlignTable['u499'] = 'center';u214.tabIndex = 0;

u214.style.cursor = 'pointer';
$axure.eventManager.click('u214', function(e) {

if (true) {

	SetPanelVisibility('u614','','none',500);

}
});
gv_vAlignTable['u221'] = 'top';gv_vAlignTable['u440'] = 'top';gv_vAlignTable['u246'] = 'center';gv_vAlignTable['u82'] = 'center';gv_vAlignTable['u652'] = 'top';gv_vAlignTable['u677'] = 'center';gv_vAlignTable['u274'] = 'top';u208.tabIndex = 0;

u208.style.cursor = 'pointer';
$axure.eventManager.click('u208', function(e) {

if (true) {

	SetPanelVisibility('u614','','none',500);

}
});
gv_vAlignTable['u242'] = 'center';gv_vAlignTable['u461'] = 'top';gv_vAlignTable['u377'] = 'center';gv_vAlignTable['u268'] = 'top';gv_vAlignTable['u639'] = 'center';gv_vAlignTable['u43'] = 'top';gv_vAlignTable['u770'] = 'center';gv_vAlignTable['u270'] = 'top';gv_vAlignTable['u67'] = 'top';gv_vAlignTable['u5'] = 'center';gv_vAlignTable['u391'] = 'top';document.getElementById('u87_img').tabIndex = 0;

u87.style.cursor = 'pointer';
$axure.eventManager.click('u87', function(e) {

if (true) {

	SetPanelVisibility('u464','','none',500);

}
});
gv_vAlignTable['u6'] = 'top';gv_vAlignTable['u100'] = 'center';gv_vAlignTable['u365'] = 'top';gv_vAlignTable['u765'] = 'center';u550.tabIndex = 0;

u550.style.cursor = 'pointer';
$axure.eventManager.click('u550', function(e) {

if (true) {

	SetPanelVisibility('u528','hidden','none',500);

}
});
gv_vAlignTable['u337'] = 'center';gv_vAlignTable['u524'] = 'top';gv_vAlignTable['u340'] = 'top';gv_vAlignTable['u146'] = 'center';gv_vAlignTable['u517'] = 'center';gv_vAlignTable['u721'] = 'top';gv_vAlignTable['u114'] = 'top';gv_vAlignTable['u333'] = 'center';gv_vAlignTable['u301'] = 'top';gv_vAlignTable['u520'] = 'top';gv_vAlignTable['u174'] = 'top';gv_vAlignTable['u545'] = 'top';gv_vAlignTable['u108'] = 'top';gv_vAlignTable['u142'] = 'top';gv_vAlignTable['u361'] = 'center';u757.tabIndex = 0;

u757.style.cursor = 'pointer';
$axure.eventManager.click('u757', function(e) {

if ((GetWidgetVisibility('u663')) == (false)) {

	SetPanelVisibility('u663','','none',500);

}
else
if ((GetWidgetVisibility('u663')) == (true)) {

	SetPanelVisibility('u663','hidden','none',500);

}
});
gv_vAlignTable['u168'] = 'top';gv_vAlignTable['u758'] = 'top';gv_vAlignTable['u170'] = 'center';gv_vAlignTable['u760'] = 'top';gv_vAlignTable['u719'] = 'top';gv_vAlignTable['u373'] = 'top';gv_vAlignTable['u9'] = 'top';gv_vAlignTable['u353'] = 'center';gv_vAlignTable['u57'] = 'top';gv_vAlignTable['u715'] = 'top';gv_vAlignTable['u779'] = 'top';gv_vAlignTable['u743'] = 'top';gv_vAlignTable['u687'] = 'top';gv_vAlignTable['u284'] = 'top';document.getElementById('u97_img').tabIndex = 0;

u97.style.cursor = 'pointer';
$axure.eventManager.click('u97', function(e) {

if (true) {

	SetPanelVisibility('u464','','none',500);

}
});
gv_vAlignTable['u58'] = 'top';gv_vAlignTable['u683'] = 'center';gv_vAlignTable['u280'] = 'top';u212.tabIndex = 0;

u212.style.cursor = 'pointer';
$axure.eventManager.click('u212', function(e) {

if (true) {

	SetPanelVisibility('u614','','none',500);

}
});
gv_vAlignTable['u237'] = 'center';gv_vAlignTable['u414'] = 'top';document.getElementById('u492_img').tabIndex = 0;

u492.style.cursor = 'pointer';
$axure.eventManager.click('u492', function(e) {

if (true) {
function waitu290e7da95ef846a3a858271cd8582e371() {
}
setTimeout(waitu290e7da95ef846a3a858271cd8582e371, 2000);

}
});
u205.tabIndex = 0;

u205.style.cursor = 'pointer';
$axure.eventManager.click('u205', function(e) {

if (true) {

	SetPanelVisibility('u614','','none',500);

}
});
gv_vAlignTable['u86'] = 'center';gv_vAlignTable['u68'] = 'top';gv_vAlignTable['u417'] = 'top';document.getElementById('u636_img').tabIndex = 0;

u636.style.cursor = 'pointer';
$axure.eventManager.click('u636', function(e) {

if (true) {

	SetPanelVisibility('u614','hidden','none',500);

}
});
gv_vAlignTable['u233'] = 'center';gv_vAlignTable['u477'] = 'center';gv_vAlignTable['u503'] = 'center';gv_vAlignTable['u261'] = 'top';gv_vAlignTable['u632'] = 'top';gv_vAlignTable['u657'] = 'top';gv_vAlignTable['u439'] = 'center';gv_vAlignTable['u266'] = 'top';gv_vAlignTable['u248'] = 'center';gv_vAlignTable['u41'] = 'top';gv_vAlignTable['u679'] = 'center';gv_vAlignTable['u47'] = 'top';gv_vAlignTable['u78'] = 'top';gv_vAlignTable['u184'] = 'top';gv_vAlignTable['u363'] = 'top';gv_vAlignTable['u583'] = 'top';gv_vAlignTable['u180'] = 'center';gv_vAlignTable['u112'] = 'top';gv_vAlignTable['u59'] = 'top';u514.tabIndex = 0;

u514.style.cursor = 'pointer';
$axure.eventManager.click('u514', function(e) {

if (true) {
function waituc9c637df753e421ea116ac26eb7544541() {

	self.location.href=$axure.globalVariableProvider.getLinkUrl('Take_Label.html');
}
setTimeout(waituc9c637df753e421ea116ac26eb7544541, 300);

}
});
gv_vAlignTable['u392'] = 'top';
u105.style.cursor = 'pointer';
$axure.eventManager.click('u105', function(e) {

if (((GetCheckState('u103')) == (true)) || (((GetCheckState('u105')) == (true)) || (((GetCheckState('u107')) == (true)) || (((GetCheckState('u109')) == (true)) || (((GetCheckState('u111')) == (true)) || (((GetCheckState('u113')) == (true)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || ((GetCheckState('u121')) == (true))))))))))) {

	SetPanelVisibility('u475','','none',500);

}
else
if (((GetCheckState('u103')) == (false)) || (((GetCheckState('u105')) == (false)) || (((GetCheckState('u107')) == (false)) || (((GetCheckState('u109')) == (false)) || (((GetCheckState('u111')) == (false)) || (((GetCheckState('u113')) == (false)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || ((GetCheckState('u121')) == (true))))))))))) {

	SetPanelVisibility('u475','hidden','none',500);

}
});
gv_vAlignTable['u324'] = 'center';gv_vAlignTable['u140'] = 'center';u511.tabIndex = 0;

u511.style.cursor = 'pointer';
$axure.eventManager.click('u511', function(e) {

if (true) {
function waitufc0bb016a2f64a90bb2fafa701dbcab71() {

	self.location.href=$axure.globalVariableProvider.getLinkUrl('Select_Consumption.html');
}
setTimeout(waitufc0bb016a2f64a90bb2fafa701dbcab71, 300);

}
});
gv_vAlignTable['u317'] = 'top';gv_vAlignTable['u96'] = 'center';gv_vAlignTable['u90'] = 'center';gv_vAlignTable['u723'] = 'top';gv_vAlignTable['u320'] = 'center';gv_vAlignTable['u345'] = 'top';gv_vAlignTable['u532'] = 'top';gv_vAlignTable['u751'] = 'top';gv_vAlignTable['u776'] = 'center';gv_vAlignTable['u339'] = 'top';gv_vAlignTable['u558'] = 'top';gv_vAlignTable['u13'] = 'top';gv_vAlignTable['u560'] = 'top';gv_vAlignTable['u148'] = 'center';gv_vAlignTable['u519'] = 'center';gv_vAlignTable['u772'] = 'center';gv_vAlignTable['u579'] = 'center';gv_vAlignTable['u311'] = 'center';gv_vAlignTable['u759'] = 'top';gv_vAlignTable['u55'] = 'top';gv_vAlignTable['u296'] = 'center';gv_vAlignTable['u463'] = 'top';gv_vAlignTable['u490'] = 'top';gv_vAlignTable['u3'] = 'center';gv_vAlignTable['u483'] = 'center';gv_vAlignTable['u755'] = 'center';gv_vAlignTable['u695'] = 'top';gv_vAlignTable['u292'] = 'center';gv_vAlignTable['u224'] = 'top';gv_vAlignTable['u689'] = 'top';gv_vAlignTable['u709'] = 'top';gv_vAlignTable['u411'] = 'top';u436.tabIndex = 0;

u436.style.cursor = 'pointer';
$axure.eventManager.click('u436', function(e) {

if (true) {

	SetPanelState('u286', 'pd2u286','swing','down',500,'swing','down',500);

	SetPanelState('u303', 'pd3u303','none','',500,'none','',500);

}
});
gv_vAlignTable['u404'] = 'center';gv_vAlignTable['u623'] = 'top';gv_vAlignTable['u220'] = 'center';gv_vAlignTable['u616'] = 'center';gv_vAlignTable['u432'] = 'top';gv_vAlignTable['u457'] = 'center';u239.tabIndex = 0;

u239.style.cursor = 'pointer';
$axure.eventManager.click('u239', function(e) {

if (true) {

	SetPanelVisibility('u240','','none',500);

}
});
document.getElementById('u458_img').tabIndex = 0;

u458.style.cursor = 'pointer';
$axure.eventManager.click('u458', function(e) {

if (true) {

	SetPanelState('u442', 'pd0u442','swing','up',500,'swing','up',500);
function waitu37666a09a7cd4798a2f212371ffd28341() {

	SetPanelVisibility('u442','hidden','none',500);
}
setTimeout(waitu37666a09a7cd4798a2f212371ffd28341, 1000);

}
});
gv_vAlignTable['u460'] = 'top';gv_vAlignTable['u419'] = 'center';document.getElementById('u638_img').tabIndex = 0;

u638.style.cursor = 'pointer';
$axure.eventManager.click('u638', function(e) {

if ((GetPanelState('u643')) == ('pd0u643')) {

	SetPanelState('u643', 'pd3u643','none','',500,'none','',500);

}
else
if (((GetPanelState('u643')) != ('pd0u643')) && (((GetPanelState('u643')) != ('pd1u643')) && ((GetPanelState('u643')) != ('pd4u643')))) {

	SetPanelStatePrevious('u643',false,'none','',500,'none','',500);

}
else
if ((GetPanelState('u643')) == ('pd1u643')) {

	SetPanelState('u643', 'pd1u643','none','',500,'none','',500);

}
else
if ((GetPanelState('u643')) == ('pd4u643')) {

	SetPanelState('u643', 'pd0u643','none','',500,'none','',500);

}
});
document.getElementById('u21_img').tabIndex = 0;

u21.style.cursor = 'pointer';
$axure.eventManager.click('u21', function(e) {

if (true) {

	SetPanelVisibility('u20','hidden','none',500);

	SendToBack("u20");

}
});
gv_vAlignTable['u673'] = 'center';gv_vAlignTable['u739'] = 'top';gv_vAlignTable['u479'] = 'center';gv_vAlignTable['u27'] = 'top';gv_vAlignTable['u659'] = 'center';gv_vAlignTable['u45'] = 'top';gv_vAlignTable['u387'] = 'center';gv_vAlignTable['u717'] = 'top';gv_vAlignTable['u788'] = 'center';gv_vAlignTable['u390'] = 'top';gv_vAlignTable['u196'] = 'center';gv_vAlignTable['u786'] = 'center';gv_vAlignTable['u383'] = 'center';u595.tabIndex = 0;

u595.style.cursor = 'pointer';
$axure.eventManager.click('u595', function(e) {

if (true) {

	SetPanelVisibility('u528','hidden','none',500);

}
});
gv_vAlignTable['u33'] = 'top';gv_vAlignTable['u192'] = 'top';gv_vAlignTable['u782'] = 'top';gv_vAlignTable['u38'] = 'top';
u117.style.cursor = 'pointer';
$axure.eventManager.click('u117', function(e) {

if (((GetCheckState('u103')) == (true)) || (((GetCheckState('u105')) == (true)) || (((GetCheckState('u107')) == (true)) || (((GetCheckState('u109')) == (true)) || (((GetCheckState('u111')) == (true)) || (((GetCheckState('u113')) == (true)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || ((GetCheckState('u121')) == (true))))))))))) {

	SetPanelVisibility('u475','','none',500);

}
else
if (((GetCheckState('u103')) == (false)) || (((GetCheckState('u105')) == (false)) || (((GetCheckState('u107')) == (false)) || (((GetCheckState('u109')) == (false)) || (((GetCheckState('u111')) == (false)) || (((GetCheckState('u113')) == (false)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || ((GetCheckState('u121')) == (true))))))))))) {

	SetPanelVisibility('u475','hidden','none',500);

}
});
gv_vAlignTable['u707'] = 'top';gv_vAlignTable['u523'] = 'top';gv_vAlignTable['u398'] = 'center';gv_vAlignTable['u120'] = 'top';gv_vAlignTable['u735'] = 'top';gv_vAlignTable['u705'] = 'top';u551.tabIndex = 0;

u551.style.cursor = 'pointer';
$axure.eventManager.click('u551', function(e) {

if (true) {

	SetPanelState('u528', 'pd0u528','none','',500,'none','',500);

}
});
gv_vAlignTable['u357'] = 'center';gv_vAlignTable['u576'] = 'top';gv_vAlignTable['u94'] = 'center';gv_vAlignTable['u763'] = 'top';gv_vAlignTable['u30'] = 'top';gv_vAlignTable['u731'] = 'top';u756.tabIndex = 0;

u756.style.cursor = 'pointer';
$axure.eventManager.click('u756', function(e) {

if (true) {

	SetPanelVisibility('u663','hidden','none',500);

}
});
gv_vAlignTable['u11'] = 'center';gv_vAlignTable['u572'] = 'top';gv_vAlignTable['u379'] = 'center';u17.tabIndex = 0;

u17.style.cursor = 'pointer';
$axure.eventManager.click('u17', function(e) {

if (true) {

	self.location.href=$axure.globalVariableProvider.getLinkUrl('Help_Setting.html');

}
});
gv_vAlignTable['u76'] = 'top';gv_vAlignTable['u88'] = 'center';gv_vAlignTable['u559'] = 'top';gv_vAlignTable['u778'] = 'center';gv_vAlignTable['u35'] = 'top';gv_vAlignTable['u729'] = 'top';gv_vAlignTable['u290'] = 'top';gv_vAlignTable['u1'] = 'center';gv_vAlignTable['u283'] = 'top';gv_vAlignTable['u489'] = 'center';u211.tabIndex = 0;

u211.style.cursor = 'pointer';
$axure.eventManager.click('u211', function(e) {

if (true) {

	SetPanelVisibility('u614','','none',500);

}
});
gv_vAlignTable['u607'] = 'top';gv_vAlignTable['u204'] = 'center';document.getElementById('u85_img').tabIndex = 0;

u85.style.cursor = 'pointer';
$axure.eventManager.click('u85', function(e) {

if (true) {

	SetPanelVisibility('u464','','none',500);

}
});
gv_vAlignTable['u75'] = 'top';gv_vAlignTable['u667'] = 'top';gv_vAlignTable['u610'] = 'top';gv_vAlignTable['u264'] = 'top';gv_vAlignTable['u635'] = 'center';document.getElementById('u232_img').tabIndex = 0;

u232.style.cursor = 'pointer';
$axure.eventManager.click('u232', function(e) {

if (true) {

	SetPanelVisibility('u216','hidden','none',500);

}
});
gv_vAlignTable['u451'] = 'center';gv_vAlignTable['u257'] = 'center';document.getElementById('u476_img').tabIndex = 0;

u476.style.cursor = 'pointer';
$axure.eventManager.click('u476', function(e) {

if (true) {

	SetPanelVisibility('u464','','none',500);

}
});
gv_vAlignTable['u84'] = 'center';gv_vAlignTable['u444'] = 'center';gv_vAlignTable['u260'] = 'top';gv_vAlignTable['u631'] = 'top';gv_vAlignTable['u472'] = 'center';gv_vAlignTable['u279'] = 'top';gv_vAlignTable['u611'] = 'top';gv_vAlignTable['u66'] = 'top';gv_vAlignTable['u618'] = 'center';gv_vAlignTable['u459'] = 'center';gv_vAlignTable['u227'] = 'center';gv_vAlignTable['u190'] = 'top';gv_vAlignTable['u395'] = 'center';gv_vAlignTable['u79'] = 'top';gv_vAlignTable['u389'] = 'top';
u111.style.cursor = 'pointer';
$axure.eventManager.click('u111', function(e) {

if (((GetCheckState('u103')) == (true)) || (((GetCheckState('u105')) == (true)) || (((GetCheckState('u107')) == (true)) || (((GetCheckState('u109')) == (true)) || (((GetCheckState('u111')) == (true)) || (((GetCheckState('u113')) == (true)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || ((GetCheckState('u121')) == (true))))))))))) {

	SetPanelVisibility('u475','','none',500);

}
else
if (((GetCheckState('u103')) == (false)) || (((GetCheckState('u105')) == (false)) || (((GetCheckState('u107')) == (false)) || (((GetCheckState('u109')) == (false)) || (((GetCheckState('u111')) == (false)) || (((GetCheckState('u113')) == (false)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || ((GetCheckState('u121')) == (true))))))))))) {

	SetPanelVisibility('u475','hidden','none',500);

}
});
gv_vAlignTable['u136'] = 'top';gv_vAlignTable['u507'] = 'center';gv_vAlignTable['u104'] = 'top';gv_vAlignTable['u198'] = 'top';u510.tabIndex = 0;

u510.style.cursor = 'pointer';
$axure.eventManager.click('u510', function(e) {

if (true) {

	SetPanelVisibility('u442','','none',500);

	SetPanelState('u442', 'pd1u442','swing','down',500,'swing','down',500);

}
});
gv_vAlignTable['u164'] = 'center';gv_vAlignTable['u535'] = 'center';document.getElementById('u754_img').tabIndex = 0;

u754.style.cursor = 'pointer';
$axure.eventManager.click('u754', function(e) {

if (true) {

	SetPanelVisibility('u663','hidden','none',500);

}
});
gv_vAlignTable['u132'] = 'center';u351.tabIndex = 0;

u351.style.cursor = 'pointer';
$axure.eventManager.click('u351', function(e) {

if (true) {

	SetPanelState('u286', 'pd0u286','swing','down',500,'swing','down',500);

	SetPanelState('u303', 'pd0u303','none','',500,'none','',500);

}
});
gv_vAlignTable['u747'] = 'top';gv_vAlignTable['u158'] = 'top';gv_vAlignTable['u344'] = 'center';u563.tabIndex = 0;

u563.style.cursor = 'pointer';
$axure.eventManager.click('u563', function(e) {

if (true) {

	SetPanelVisibility('u528','','none',500);

	SetPanelState('u528', 'pd0u528','none','',500,'none','',500);
function waitua77b4f50cf63431ab323e9733b6b344a1() {

	SetPanelState('u528', 'pd1u528','none','',500,'none','',500);
function waitu769d451791f244e297eed958209cdbd81() {

	SetPanelState('u528', 'pd2u528','none','',500,'none','',500);
}
setTimeout(waitu769d451791f244e297eed958209cdbd81, 3000);
}
setTimeout(waitua77b4f50cf63431ab323e9733b6b344a1, 3500);

}
});
gv_vAlignTable['u160'] = 'top';gv_vAlignTable['u40'] = 'top';
u119.style.cursor = 'pointer';
$axure.eventManager.click('u119', function(e) {

if (((GetCheckState('u103')) == (true)) || (((GetCheckState('u105')) == (true)) || (((GetCheckState('u107')) == (true)) || (((GetCheckState('u109')) == (true)) || (((GetCheckState('u111')) == (true)) || (((GetCheckState('u113')) == (true)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || ((GetCheckState('u121')) == (true))))))))))) {

	SetPanelVisibility('u475','','none',500);

}
else
if (((GetCheckState('u103')) == (false)) || (((GetCheckState('u105')) == (false)) || (((GetCheckState('u107')) == (false)) || (((GetCheckState('u109')) == (false)) || (((GetCheckState('u111')) == (false)) || (((GetCheckState('u113')) == (false)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || ((GetCheckState('u121')) == (true))))))))))) {

	SetPanelVisibility('u475','hidden','none',500);

}
});
gv_vAlignTable['u338'] = 'top';gv_vAlignTable['u92'] = 'center';gv_vAlignTable['u372'] = 'center';gv_vAlignTable['u711'] = 'top';gv_vAlignTable['u56'] = 'top';gv_vAlignTable['u8'] = 'center';gv_vAlignTable['u359'] = 'center';gv_vAlignTable['u15'] = 'center';gv_vAlignTable['u74'] = 'top';gv_vAlignTable['u289'] = 'top';
u121.style.cursor = 'pointer';
$axure.eventManager.click('u121', function(e) {

if (((GetCheckState('u103')) == (true)) || (((GetCheckState('u105')) == (true)) || (((GetCheckState('u107')) == (true)) || (((GetCheckState('u109')) == (true)) || (((GetCheckState('u111')) == (true)) || (((GetCheckState('u113')) == (true)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || ((GetCheckState('u121')) == (true))))))))))) {

	SetPanelVisibility('u475','','none',500);

}
else
if (((GetCheckState('u103')) == (false)) || (((GetCheckState('u105')) == (false)) || (((GetCheckState('u107')) == (false)) || (((GetCheckState('u109')) == (false)) || (((GetCheckState('u111')) == (false)) || (((GetCheckState('u113')) == (false)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || ((GetCheckState('u121')) == (true))))))))))) {

	SetPanelVisibility('u475','hidden','none',500);

}
});
gv_vAlignTable['u527'] = 'center';gv_vAlignTable['u223'] = 'top';gv_vAlignTable['u467'] = 'top';gv_vAlignTable['u254'] = 'center';gv_vAlignTable['u410'] = 'top';gv_vAlignTable['u435'] = 'top';gv_vAlignTable['u622'] = 'top';gv_vAlignTable['u276'] = 'top';gv_vAlignTable['u429'] = 'top';gv_vAlignTable['u244'] = 'center';gv_vAlignTable['u431'] = 'top';document.getElementById('u456_img').tabIndex = 0;

u456.style.cursor = 'pointer';
$axure.eventManager.click('u456', function(e) {

if (true) {

	SetPanelState('u442', 'pd0u442','swing','up',500,'swing','up',500);
function waitu7b4b19df9e244549adbe4050b0ab65da1() {

	SetPanelVisibility('u442','hidden','none',500);
}
setTimeout(waitu7b4b19df9e244549adbe4050b0ab65da1, 1000);

}
});
gv_vAlignTable['u675'] = 'center';u238.tabIndex = 0;

u238.style.cursor = 'pointer';
$axure.eventManager.click('u238', function(e) {

if (true) {

	SetPanelVisibility('u216','hidden','none',500);

}
});
gv_vAlignTable['u272'] = 'top';gv_vAlignTable['u46'] = 'top';gv_vAlignTable['u671'] = 'center';gv_vAlignTable['u259'] = 'top';document.getElementById('u478_img').tabIndex = 0;

u478.style.cursor = 'pointer';
$axure.eventManager.click('u478', function(e) {

if (true) {

	SetPanelVisibility('u525','','none',500);

SetCheckState('u103', false);

SetCheckState('u105', false);

SetCheckState('u107', false);

SetCheckState('u109', false);

SetCheckState('u111', false);

SetCheckState('u113', false);

SetCheckState('u115', false);

SetCheckState('u117', false);

SetCheckState('u119', false);

SetCheckState('u121', false);

}
});
gv_vAlignTable['u64'] = 'top';gv_vAlignTable['u727'] = 'top';gv_vAlignTable['u621'] = 'center';document.getElementById('u99_img').tabIndex = 0;

u99.style.cursor = 'pointer';
$axure.eventManager.click('u99', function(e) {

if (true) {

	SetPanelVisibility('u464','','none',500);

}
});
gv_vAlignTable['u307'] = 'center';document.getElementById('u526_img').tabIndex = 0;

u526.style.cursor = 'pointer';
$axure.eventManager.click('u526', function(e) {

if (true) {

	SetPanelVisibility('u20','','none',500);

	BringToFront("u20");

	SetPanelVisibility('u475','hidden','none',500);

}
});
gv_vAlignTable['u781'] = 'top';gv_vAlignTable['u713'] = 'top';gv_vAlignTable['u116'] = 'top';gv_vAlignTable['u335'] = 'center';gv_vAlignTable['u703'] = 'top';gv_vAlignTable['u522'] = 'center';gv_vAlignTable['u176'] = 'top';gv_vAlignTable['u766'] = 'top';gv_vAlignTable['u329'] = 'center';gv_vAlignTable['u144'] = 'top';u515.tabIndex = 0;

u515.style.cursor = 'pointer';
$axure.eventManager.click('u515', function(e) {

if (true) {
function waitu8263349dccb34b40af951476307edc591() {

	self.location.href=$axure.globalVariableProvider.getLinkUrl('Take_Barcode.html');
}
setTimeout(waitu8263349dccb34b40af951476307edc591, 300);

}
});
gv_vAlignTable['u331'] = 'center';gv_vAlignTable['u305'] = 'center';gv_vAlignTable['u575'] = 'top';gv_vAlignTable['u138'] = 'center';gv_vAlignTable['u509'] = 'center';gv_vAlignTable['u172'] = 'center';gv_vAlignTable['u762'] = 'center';gv_vAlignTable['u569'] = 'top';gv_vAlignTable['u36'] = 'top';gv_vAlignTable['u318'] = 'top';gv_vAlignTable['u571'] = 'center';gv_vAlignTable['u65'] = 'top';gv_vAlignTable['u54'] = 'top';gv_vAlignTable['u72'] = 'top';gv_vAlignTable['u685'] = 'top';gv_vAlignTable['u282'] = 'top';document.getElementById('u89_img').tabIndex = 0;

u89.style.cursor = 'pointer';
$axure.eventManager.click('u89', function(e) {

if (true) {

	SetPanelVisibility('u464','','none',500);

}
});
u207.tabIndex = 0;

u207.style.cursor = 'pointer';
$axure.eventManager.click('u207', function(e) {

if (true) {

	SetPanelVisibility('u614','','none',500);

}
});
gv_vAlignTable['u693'] = 'top';u613.tabIndex = 0;

u613.style.cursor = 'pointer';
$axure.eventManager.click('u613', function(e) {

if (true) {

	SetPanelVisibility('u528','','none',500);

	SetPanelState('u528', 'pd0u528','none','',500,'none','',500);
function waituaf87f87d7d3d410eb0abf4f11b4fe7731() {

	SetPanelState('u528', 'pd1u528','none','',500,'none','',500);
function waitu0b53d15ad0664384af3efdad93374d891() {

	SetPanelState('u528', 'pd2u528','none','',500,'none','',500);
}
setTimeout(waitu0b53d15ad0664384af3efdad93374d891, 3000);
}
setTimeout(waituaf87f87d7d3d410eb0abf4f11b4fe7731, 3500);

}
});
gv_vAlignTable['u267'] = 'top';u210.tabIndex = 0;

u210.style.cursor = 'pointer';
$axure.eventManager.click('u210', function(e) {

if (true) {

	SetPanelVisibility('u614','','none',500);

}
});
gv_vAlignTable['u235'] = 'center';gv_vAlignTable['u641'] = 'center';gv_vAlignTable['u666'] = 'top';gv_vAlignTable['u229'] = 'center';document.getElementById('u634_img').tabIndex = 0;

u634.style.cursor = 'pointer';
$axure.eventManager.click('u634', function(e) {

if (true) {

	SetPanelVisibility('u614','hidden','none',500);

}
});
gv_vAlignTable['u231'] = 'center';gv_vAlignTable['u627'] = 'center';gv_vAlignTable['u409'] = 'top';gv_vAlignTable['u662'] = 'top';gv_vAlignTable['u298'] = 'top';document.getElementById('u469_img').tabIndex = 0;

u469.style.cursor = 'pointer';
$axure.eventManager.click('u469', function(e) {

if (true) {

	SetPanelVisibility('u464','hidden','none',500);

}
});
gv_vAlignTable['u655'] = 'top';gv_vAlignTable['u218'] = 'center';document.getElementById('u471_img').tabIndex = 0;

u471.style.cursor = 'pointer';
$axure.eventManager.click('u471', function(e) {

if (true) {

	SetPanelVisibility('u464','hidden','none',500);

}
});
gv_vAlignTable['u278'] = 'top';gv_vAlignTable['u44'] = 'top';gv_vAlignTable['u681'] = 'center';gv_vAlignTable['u62'] = 'top';gv_vAlignTable['u186'] = 'center';gv_vAlignTable['u585'] = 'center';gv_vAlignTable['u182'] = 'top';u16.tabIndex = 0;

u16.style.cursor = 'pointer';
$axure.eventManager.click('u16', function(e) {

if (true) {

	self.location.href=$axure.globalVariableProvider.getLinkUrl('Login.html');

}
});

u107.style.cursor = 'pointer';
$axure.eventManager.click('u107', function(e) {

if (((GetCheckState('u103')) == (true)) || (((GetCheckState('u105')) == (true)) || (((GetCheckState('u107')) == (true)) || (((GetCheckState('u109')) == (true)) || (((GetCheckState('u111')) == (true)) || (((GetCheckState('u113')) == (true)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || ((GetCheckState('u121')) == (true))))))))))) {

	SetPanelVisibility('u475','','none',500);

}
else
if (((GetCheckState('u103')) == (false)) || (((GetCheckState('u105')) == (false)) || (((GetCheckState('u107')) == (false)) || (((GetCheckState('u109')) == (false)) || (((GetCheckState('u111')) == (false)) || (((GetCheckState('u113')) == (false)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || ((GetCheckState('u121')) == (true))))))))))) {

	SetPanelVisibility('u475','hidden','none',500);

}
});
u326.tabIndex = 0;

u326.style.cursor = 'pointer';
$axure.eventManager.click('u326', function(e) {

if (true) {

	SetPanelState('u286', 'pd0u286','swing','down',500,'swing','down',500);

	SetPanelState('u303', 'pd0u303','none','',500,'none','',500);

}
});
gv_vAlignTable['u316'] = 'top';gv_vAlignTable['u581'] = 'top';u513.tabIndex = 0;

u513.style.cursor = 'pointer';
$axure.eventManager.click('u513', function(e) {

if (true) {
function waitub68a3a192827468b973c974c24bc69731() {

	self.location.href=$axure.globalVariableProvider.getLinkUrl('Take_Photo.html');
}
setTimeout(waitub68a3a192827468b973c974c24bc69731, 300);

}
});
gv_vAlignTable['u388'] = 'top';gv_vAlignTable['u110'] = 'top';gv_vAlignTable['u661'] = 'center';gv_vAlignTable['u725'] = 'top';gv_vAlignTable['u152'] = 'top';
u103.style.cursor = 'pointer';
$axure.eventManager.click('u103', function(e) {

if (((GetCheckState('u103')) == (true)) || (((GetCheckState('u105')) == (true)) || (((GetCheckState('u107')) == (true)) || (((GetCheckState('u109')) == (true)) || (((GetCheckState('u111')) == (true)) || (((GetCheckState('u113')) == (true)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || ((GetCheckState('u121')) == (true))))))))))) {

	SetPanelVisibility('u475','','none',500);

}
else
if (((GetCheckState('u103')) == (false)) || (((GetCheckState('u105')) == (false)) || (((GetCheckState('u107')) == (false)) || (((GetCheckState('u109')) == (false)) || (((GetCheckState('u111')) == (false)) || (((GetCheckState('u113')) == (false)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || ((GetCheckState('u121')) == (true))))))))))) {

	SetPanelVisibility('u475','hidden','none',500);

}
});
u322.tabIndex = 0;

u322.style.cursor = 'pointer';
$axure.eventManager.click('u322', function(e) {

if (true) {

	SetPanelState('u286', 'pd2u286','swing','down',500,'swing','down',500);

	SetPanelState('u303', 'pd3u303','none','',500,'none','',500);

}
});
u347.tabIndex = 0;

u347.style.cursor = 'pointer';
$axure.eventManager.click('u347', function(e) {

if (true) {

	SetPanelState('u286', 'pd1u286','swing','down',500,'swing','down',500);

	SetPanelState('u303', 'pd5u303','none','',500,'none','',500);

}
});
gv_vAlignTable['u566'] = 'top';document.getElementById('u93_img').tabIndex = 0;

u93.style.cursor = 'pointer';
$axure.eventManager.click('u93', function(e) {

if (true) {

	SetPanelVisibility('u464','','none',500);

}
});
gv_vAlignTable['u315'] = 'top';gv_vAlignTable['u753'] = 'top';gv_vAlignTable['u741'] = 'top';gv_vAlignTable['u350'] = 'top';gv_vAlignTable['u156'] = 'center';u375.tabIndex = 0;

u375.style.cursor = 'pointer';
$axure.eventManager.click('u375', function(e) {

if (true) {

	SetPanelState('u286', 'pd0u286','swing','down',500,'swing','down',500);

	SetPanelState('u303', 'pd0u303','none','',500,'none','',500);

}
});
gv_vAlignTable['u309'] = 'center';u562.tabIndex = 0;

u562.style.cursor = 'pointer';
$axure.eventManager.click('u562', function(e) {

if (true) {

	SetPanelVisibility('u528','hidden','none',500);

}
});
gv_vAlignTable['u369'] = 'top';gv_vAlignTable['u530'] = 'center';gv_vAlignTable['u555'] = 'top';gv_vAlignTable['u118'] = 'top';gv_vAlignTable['u178'] = 'center';gv_vAlignTable['u549'] = 'top';gv_vAlignTable['u768'] = 'center';gv_vAlignTable['u34'] = 'top';gv_vAlignTable['u37'] = 'top';gv_vAlignTable['u52'] = 'top';gv_vAlignTable['u423'] = 'center';gv_vAlignTable['u789'] = 'top';gv_vAlignTable['u485'] = 'center';gv_vAlignTable['u26'] = 'center';gv_vAlignTable['u321'] = 'top';gv_vAlignTable['u294'] = 'top';gv_vAlignTable['u474'] = 'center';gv_vAlignTable['u481'] = 'center';gv_vAlignTable['u413'] = 'top';gv_vAlignTable['u288'] = 'center';gv_vAlignTable['u406'] = 'center';gv_vAlignTable['u625'] = 'center';gv_vAlignTable['u252'] = 'center';gv_vAlignTable['u222'] = 'top';u441.tabIndex = 0;

u441.style.cursor = 'pointer';
$axure.eventManager.click('u441', function(e) {

if (true) {

	SetPanelState('u286', 'pd3u286','swing','down',500,'swing','down',500);

	SetPanelState('u303', 'pd4u303','none','',500,'none','',500);

}
});
document.getElementById('u247_img').tabIndex = 0;

u247.style.cursor = 'pointer';
$axure.eventManager.click('u247', function(e) {

if (true) {

	SetPanelVisibility('u240','hidden','none',500);

}
});
gv_vAlignTable['u466'] = 'center';document.getElementById('u83_img').tabIndex = 0;

u83.style.cursor = 'pointer';
$axure.eventManager.click('u83', function(e) {

if (true) {

	SetPanelVisibility('u464','','none',500);

}
});
u215.tabIndex = 0;

u215.style.cursor = 'pointer';
$axure.eventManager.click('u215', function(e) {

if (true) {

	SetPanelVisibility('u216','','none',500);

}
});
gv_vAlignTable['u434'] = 'center';gv_vAlignTable['u653'] = 'top';gv_vAlignTable['u402'] = 'center';gv_vAlignTable['u69'] = 'top';gv_vAlignTable['u427'] = 'center';u209.tabIndex = 0;

u209.style.cursor = 'pointer';
$axure.eventManager.click('u209', function(e) {

if (true) {

	SetPanelVisibility('u614','','none',500);

}
});
gv_vAlignTable['u428'] = 'top';gv_vAlignTable['u462'] = 'top';gv_vAlignTable['u269'] = 'top';gv_vAlignTable['u430'] = 'top';gv_vAlignTable['u455'] = 'top';gv_vAlignTable['u271'] = 'top';gv_vAlignTable['u449'] = 'center';gv_vAlignTable['u668'] = 'top';gv_vAlignTable['u24'] = 'center';gv_vAlignTable['u162'] = 'center';gv_vAlignTable['u277'] = 'top';gv_vAlignTable['u42'] = 'top';gv_vAlignTable['u385'] = 'center';gv_vAlignTable['u597'] = 'center';gv_vAlignTable['u194'] = 'center';gv_vAlignTable['u784'] = 'center';gv_vAlignTable['u126'] = 'top';gv_vAlignTable['u150'] = 'top';gv_vAlignTable['u416'] = 'center';gv_vAlignTable['u749'] = 'top';gv_vAlignTable['u381'] = 'center';gv_vAlignTable['u313'] = 'center';gv_vAlignTable['u188'] = 'center';gv_vAlignTable['u774'] = 'center';gv_vAlignTable['u154'] = 'center';gv_vAlignTable['u780'] = 'top';gv_vAlignTable['u122'] = 'top';gv_vAlignTable['u341'] = 'top';gv_vAlignTable['u366'] = 'top';gv_vAlignTable['u737'] = 'top';
u115.style.cursor = 'pointer';
$axure.eventManager.click('u115', function(e) {

if (((GetCheckState('u103')) == (true)) || (((GetCheckState('u105')) == (true)) || (((GetCheckState('u107')) == (true)) || (((GetCheckState('u109')) == (true)) || (((GetCheckState('u111')) == (true)) || (((GetCheckState('u113')) == (true)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || ((GetCheckState('u121')) == (true))))))))))) {

	SetPanelVisibility('u475','','none',500);

}
else
if (((GetCheckState('u103')) == (false)) || (((GetCheckState('u105')) == (false)) || (((GetCheckState('u107')) == (false)) || (((GetCheckState('u109')) == (false)) || (((GetCheckState('u111')) == (false)) || (((GetCheckState('u113')) == (false)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || ((GetCheckState('u121')) == (true))))))))))) {

	SetPanelVisibility('u475','hidden','none',500);

}
});
gv_vAlignTable['u553'] = 'center';gv_vAlignTable['u48'] = 'top';gv_vAlignTable['u302'] = 'top';u327.tabIndex = 0;

u327.style.cursor = 'pointer';
$axure.eventManager.click('u327', function(e) {

if (true) {

	SetPanelState('u286', 'pd3u286','swing','down',500,'swing','down',500);

	SetPanelState('u303', 'pd4u303','none','',500,'none','',500);

}
});

u109.style.cursor = 'pointer';
$axure.eventManager.click('u109', function(e) {

if (((GetCheckState('u103')) == (true)) || (((GetCheckState('u105')) == (true)) || (((GetCheckState('u107')) == (true)) || (((GetCheckState('u109')) == (true)) || (((GetCheckState('u111')) == (true)) || (((GetCheckState('u113')) == (true)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || ((GetCheckState('u121')) == (true))))))))))) {

	SetPanelVisibility('u475','','none',500);

}
else
if (((GetCheckState('u103')) == (false)) || (((GetCheckState('u105')) == (false)) || (((GetCheckState('u107')) == (false)) || (((GetCheckState('u109')) == (false)) || (((GetCheckState('u111')) == (false)) || (((GetCheckState('u113')) == (false)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || ((GetCheckState('u121')) == (true))))))))))) {

	SetPanelVisibility('u475','hidden','none',500);

}
});
document.getElementById('u91_img').tabIndex = 0;

u91.style.cursor = 'pointer';
$axure.eventManager.click('u91', function(e) {

if (true) {

	SetPanelVisibility('u464','','none',500);

}
});
gv_vAlignTable['u362'] = 'top';gv_vAlignTable['u733'] = 'top';gv_vAlignTable['u701'] = 'top';gv_vAlignTable['u355'] = 'center';gv_vAlignTable['u574'] = 'center';gv_vAlignTable['u349'] = 'center';gv_vAlignTable['u568'] = 'center';gv_vAlignTable['u73'] = 'top';gv_vAlignTable['u629'] = 'center';gv_vAlignTable['u32'] = 'top';