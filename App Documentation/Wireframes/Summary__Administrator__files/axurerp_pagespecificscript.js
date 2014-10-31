for(var i = 0; i < 798; i++) { var scriptId = 'u' + i; window[scriptId] = document.getElementById(scriptId); }

$axure.eventManager.pageLoad(
function (e) {

});

if (bIE) document.getElementById('u281').attachEvent("onmousedown", function(e) { StartDragWidget(e, 'u281'); });
else {
    document.getElementById('u281').addEventListener("mousedown", function(e) { StartDragWidget(e, 'u281'); }, true);
    document.getElementById('u281').addEventListener("touchstart", function(e) { StartDragWidget(e, 'u281'); }, true);
}

widgetIdToDragFunction['u281'] = function() {
var e = windowEvent;

if (true) {

	SetPanelStateNext('u281',false,'swing','down',500,'swing','down',500);

}

}

if (bIE) document.getElementById('u311').attachEvent("onmousedown", function(e) { StartDragWidget(e, 'u311'); });
else {
    document.getElementById('u311').addEventListener("mousedown", function(e) { StartDragWidget(e, 'u311'); }, true);
    document.getElementById('u311').addEventListener("touchstart", function(e) { StartDragWidget(e, 'u311'); }, true);
}

widgetIdToSwipeLeftFunction['u311'] = function() {
var e = windowEvent;

if ((GetPanelState('u311')) == ('pd0u311')) {

	SetPanelState('u311', 'pd1u311','swing','left',500,'swing','left',500);

}
else
if ((GetPanelState('u311')) == ('pd2u311')) {

	SetPanelState('u311', 'pd0u311','swing','left',500,'swing','left',500);

}

}

widgetIdToSwipeRightFunction['u311'] = function() {
var e = windowEvent;

if ((GetPanelState('u311')) == ('pd0u311')) {

	SetPanelState('u311', 'pd2u311','swing','right',500,'swing','right',500);

}
else
if ((GetPanelState('u311')) == ('pd1u311')) {

	SetPanelState('u311', 'pd0u311','swing','right',500,'swing','right',500);

}

}

if (bIE) document.getElementById('u266').attachEvent("onmousedown", function(e) { StartDragWidget(e, 'u266'); });
else {
    document.getElementById('u266').addEventListener("mousedown", function(e) { StartDragWidget(e, 'u266'); }, true);
    document.getElementById('u266').addEventListener("touchstart", function(e) { StartDragWidget(e, 'u266'); }, true);
}

widgetIdToStartDragFunction['u266'] = function() {
var e = windowEvent;

if (((GetPanelState('u266')) == ('pd0u266')) || ((GetPanelState('u266')) == ('pd1u266'))) {

	SetPanelStateNext('u266',false,'swing','down',500,'swing','down',500);

}
else
if ((GetPanelState('u266')) == ('pd2u266')) {

	SetPanelState('u266', 'pd0u266','swing','down',500,'swing','down',500);

}

}
gv_vAlignTable['u285'] = 'top';gv_vAlignTable['u343'] = 'center';gv_vAlignTable['u691'] = 'center';gv_vAlignTable['u497'] = 'center';u213.tabIndex = 0;

u213.style.cursor = 'pointer';
$axure.eventManager.click('u213', function(e) {

if (true) {

	SetPanelVisibility('u622','','none',500);

}
});
gv_vAlignTable['u493'] = 'center';gv_vAlignTable['u400'] = 'top';gv_vAlignTable['u206'] = 'top';gv_vAlignTable['u241'] = 'center';gv_vAlignTable['u250'] = 'center';gv_vAlignTable['u637'] = 'center';gv_vAlignTable['u699'] = 'top';gv_vAlignTable['u202'] = 'center';gv_vAlignTable['u421'] = 'top';gv_vAlignTable['u640'] = 'top';gv_vAlignTable['u665'] = 'top';u603.tabIndex = 0;

u603.style.cursor = 'pointer';
$axure.eventManager.click('u603', function(e) {

if (true) {

	SetPanelVisibility('u536','hidden','none',500);

}
});
gv_vAlignTable['u81'] = 'top';gv_vAlignTable['u262'] = 'center';gv_vAlignTable['u633'] = 'center';gv_vAlignTable['u230'] = 'top';document.getElementById('u255_img').tabIndex = 0;

u255.style.cursor = 'pointer';
$axure.eventManager.click('u255', function(e) {

if (true) {

	SetPanelVisibility('u248','hidden','none',500);

}
});
gv_vAlignTable['u408'] = 'center';gv_vAlignTable['u442'] = 'center';gv_vAlignTable['u18'] = 'top';gv_vAlignTable['u468'] = 'top';gv_vAlignTable['u396'] = 'top';gv_vAlignTable['u63'] = 'top';gv_vAlignTable['u470'] = 'top';document.getElementById('u648_img').tabIndex = 0;

u648.style.cursor = 'pointer';
$axure.eventManager.click('u648', function(e) {

if ((GetPanelState('u651')) == ('pd0u651')) {

	SetPanelState('u651', 'pd4u651','none','',500,'none','',500);

}
else
if ((GetPanelState('u651')) == ('pd3u651')) {

	SetPanelState('u651', 'pd0u651','none','',500,'none','',500);

}
else
if (((GetPanelState('u651')) != ('pd0u651')) && ((GetPanelState('u651')) != ('pd3u651'))) {

	SetPanelStateNext('u651',false,'none','',500,'none','',500);

}
});
gv_vAlignTable['u275'] = 'top';gv_vAlignTable['u22'] = 'top';gv_vAlignTable['u425'] = 'top';gv_vAlignTable['u591'] = 'top';gv_vAlignTable['u397'] = 'top';gv_vAlignTable['u98'] = 'center';gv_vAlignTable['u584'] = 'top';
u113.style.cursor = 'pointer';
$axure.eventManager.click('u113', function(e) {

if (((GetCheckState('u111')) == (true)) || (((GetCheckState('u113')) == (true)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || (((GetCheckState('u121')) == (true)) || (((GetCheckState('u123')) == (true)) || (((GetCheckState('u125')) == (true)) || (((GetCheckState('u127')) == (true)) || ((GetCheckState('u129')) == (true))))))))))) {

	SetPanelVisibility('u483','','none',500);

}
else
if (((GetCheckState('u111')) == (false)) || (((GetCheckState('u113')) == (false)) || (((GetCheckState('u115')) == (false)) || (((GetCheckState('u117')) == (false)) || (((GetCheckState('u119')) == (false)) || (((GetCheckState('u121')) == (false)) || (((GetCheckState('u123')) == (true)) || (((GetCheckState('u125')) == (true)) || (((GetCheckState('u127')) == (true)) || ((GetCheckState('u129')) == (true))))))))))) {

	SetPanelVisibility('u483','hidden','none',500);

}
});
gv_vAlignTable['u393'] = 'center';gv_vAlignTable['u300'] = 'center';gv_vAlignTable['u106'] = 'center';gv_vAlignTable['u325'] = 'top';gv_vAlignTable['u580'] = 'top';gv_vAlignTable['u166'] = 'top';gv_vAlignTable['u792'] = 'center';gv_vAlignTable['u134'] = 'top';document.getElementById('u29_img').tabIndex = 0;

u29.style.cursor = 'pointer';
$axure.eventManager.click('u29', function(e) {

if (true) {

	SetPanelVisibility('u28','hidden','none',500);

	SendToBack("u28");

}
});
gv_vAlignTable['u102'] = 'center';
u127.style.cursor = 'pointer';
$axure.eventManager.click('u127', function(e) {

if (((GetCheckState('u111')) == (true)) || (((GetCheckState('u113')) == (true)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || (((GetCheckState('u121')) == (true)) || (((GetCheckState('u123')) == (true)) || (((GetCheckState('u125')) == (true)) || (((GetCheckState('u127')) == (true)) || ((GetCheckState('u129')) == (true))))))))))) {

	SetPanelVisibility('u483','','none',500);

}
else
if (((GetCheckState('u111')) == (false)) || (((GetCheckState('u113')) == (false)) || (((GetCheckState('u115')) == (false)) || (((GetCheckState('u117')) == (false)) || (((GetCheckState('u119')) == (false)) || (((GetCheckState('u121')) == (false)) || (((GetCheckState('u123')) == (true)) || (((GetCheckState('u125')) == (true)) || (((GetCheckState('u127')) == (true)) || ((GetCheckState('u129')) == (true))))))))))) {

	SetPanelVisibility('u483','hidden','none',500);

}
});
gv_vAlignTable['u346'] = 'top';gv_vAlignTable['u128'] = 'top';gv_vAlignTable['u130'] = 'top';gv_vAlignTable['u501'] = 'center';gv_vAlignTable['u374'] = 'top';gv_vAlignTable['u745'] = 'top';gv_vAlignTable['u308'] = 'center';gv_vAlignTable['u561'] = 'center';document.getElementById('u95_img').tabIndex = 0;

u95.style.cursor = 'pointer';
$axure.eventManager.click('u95', function(e) {

if (true) {

	SetPanelVisibility('u472','','none',500);

}
});
gv_vAlignTable['u53'] = 'top';gv_vAlignTable['u370'] = 'top';u12.tabIndex = 0;

u12.style.cursor = 'pointer';
$axure.eventManager.click('u12', function(e) {

if (true) {

    self.location.href="resources/reload.html#" + encodeURI($axure.globalVariableProvider.getLinkUrl($axure.pageData.url));

}
});
gv_vAlignTable['u71'] = 'top';gv_vAlignTable['u77'] = 'top';gv_vAlignTable['u491'] = 'center';gv_vAlignTable['u297'] = 'top';gv_vAlignTable['u265'] = 'center';document.getElementById('u484_img').tabIndex = 0;

u484.style.cursor = 'pointer';
$axure.eventManager.click('u484', function(e) {

if (true) {

	SetPanelVisibility('u472','','none',500);

}
});
gv_vAlignTable['u697'] = 'top';gv_vAlignTable['u293'] = 'top';gv_vAlignTable['u200'] = 'top';gv_vAlignTable['u480'] = 'center';gv_vAlignTable['u412'] = 'center';gv_vAlignTable['u437'] = 'top';gv_vAlignTable['u49'] = 'top';gv_vAlignTable['u624'] = 'center';gv_vAlignTable['u499'] = 'top';u214.tabIndex = 0;

u214.style.cursor = 'pointer';
$axure.eventManager.click('u214', function(e) {

if (true) {

	SetPanelVisibility('u622','','none',500);

}
});
u221.tabIndex = 0;

u221.style.cursor = 'pointer';
$axure.eventManager.click('u221', function(e) {

if (true) {

	SetPanelVisibility('u622','','none',500);

}
});
gv_vAlignTable['u440'] = 'top';u246.tabIndex = 0;

u246.style.cursor = 'pointer';
$axure.eventManager.click('u246', function(e) {

if (true) {

	SetPanelVisibility('u224','hidden','none',500);

}
});
gv_vAlignTable['u465'] = 'center';gv_vAlignTable['u82'] = 'top';gv_vAlignTable['u433'] = 'center';gv_vAlignTable['u401'] = 'top';u620.tabIndex = 0;

u620.style.cursor = 'pointer';
$axure.eventManager.click('u620', function(e) {

if (true) {

	SetPanelVisibility('u536','hidden','none',500);

}
});
gv_vAlignTable['u274'] = 'top';gv_vAlignTable['u645'] = 'center';gv_vAlignTable['u208'] = 'top';document.getElementById('u242_img').tabIndex = 0;

u242.style.cursor = 'pointer';
$axure.eventManager.click('u242', function(e) {

if (true) {

	SetPanelVisibility('u224','hidden','none',500);

}
});
gv_vAlignTable['u461'] = 'center';gv_vAlignTable['u377'] = 'top';gv_vAlignTable['u777'] = 'center';gv_vAlignTable['u268'] = 'top';gv_vAlignTable['u639'] = 'top';gv_vAlignTable['u43'] = 'top';gv_vAlignTable['u270'] = 'top';gv_vAlignTable['u448'] = 'top';gv_vAlignTable['u475'] = 'top';gv_vAlignTable['u61'] = 'top';gv_vAlignTable['u67'] = 'top';gv_vAlignTable['u5'] = 'center';gv_vAlignTable['u540'] = 'top';gv_vAlignTable['u391'] = 'center';gv_vAlignTable['u787'] = 'top';gv_vAlignTable['u87'] = 'top';gv_vAlignTable['u790'] = 'center';gv_vAlignTable['u6'] = 'top';gv_vAlignTable['u100'] = 'center';gv_vAlignTable['u783'] = 'center';
u125.style.cursor = 'pointer';
$axure.eventManager.click('u125', function(e) {

if (((GetCheckState('u111')) == (true)) || (((GetCheckState('u113')) == (true)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || (((GetCheckState('u121')) == (true)) || (((GetCheckState('u123')) == (true)) || (((GetCheckState('u125')) == (true)) || (((GetCheckState('u127')) == (true)) || ((GetCheckState('u129')) == (true))))))))))) {

	SetPanelVisibility('u483','','none',500);

}
else
if (((GetCheckState('u111')) == (false)) || (((GetCheckState('u113')) == (false)) || (((GetCheckState('u115')) == (false)) || (((GetCheckState('u117')) == (false)) || (((GetCheckState('u119')) == (false)) || (((GetCheckState('u121')) == (false)) || (((GetCheckState('u123')) == (true)) || (((GetCheckState('u125')) == (true)) || (((GetCheckState('u127')) == (true)) || ((GetCheckState('u129')) == (true))))))))))) {

	SetPanelVisibility('u483','hidden','none',500);

}
});
gv_vAlignTable['u365'] = 'center';u765.tabIndex = 0;

u765.style.cursor = 'pointer';
$axure.eventManager.click('u765', function(e) {

if ((GetWidgetVisibility('u671')) == (false)) {

	SetPanelVisibility('u671','','none',500);

}
else
if ((GetWidgetVisibility('u671')) == (true)) {

	SetPanelVisibility('u671','hidden','none',500);

}
});
gv_vAlignTable['u380'] = 'center';gv_vAlignTable['u337'] = 'center';gv_vAlignTable['u399'] = 'top';gv_vAlignTable['u146'] = 'center';gv_vAlignTable['u517'] = 'center';gv_vAlignTable['u721'] = 'top';gv_vAlignTable['u114'] = 'top';gv_vAlignTable['u333'] = 'top';gv_vAlignTable['u577'] = 'top';gv_vAlignTable['u301'] = 'top';u520.tabIndex = 0;

u520.style.cursor = 'pointer';
$axure.eventManager.click('u520', function(e) {

if (true) {

	SetPanelVisibility('u536','','none',500);

	SetPanelState('u536', 'pd0u536','none','',500,'none','',500);
function waitude3967ce88934c4d87ae6ed30c0aea281() {

	SetPanelState('u536', 'pd1u536','none','',500,'none','',500);
function waituac1872c232f44c829d71af3cc9b17b4e1() {

	SetPanelState('u536', 'pd2u536','none','',500,'none','',500);
}
setTimeout(waituac1872c232f44c829d71af3cc9b17b4e1, 3000);
}
setTimeout(waitude3967ce88934c4d87ae6ed30c0aea281, 3500);

}
});
gv_vAlignTable['u174'] = 'top';gv_vAlignTable['u108'] = 'center';gv_vAlignTable['u142'] = 'top';gv_vAlignTable['u361'] = 'center';gv_vAlignTable['u757'] = 'top';gv_vAlignTable['u168'] = 'top';gv_vAlignTable['u573'] = 'center';gv_vAlignTable['u170'] = 'center';gv_vAlignTable['u348'] = 'top';gv_vAlignTable['u719'] = 'top';gv_vAlignTable['u51'] = 'top';gv_vAlignTable['u373'] = 'top';gv_vAlignTable['u9'] = 'top';gv_vAlignTable['u353'] = 'top';gv_vAlignTable['u57'] = 'top';gv_vAlignTable['u715'] = 'top';gv_vAlignTable['u779'] = 'center';gv_vAlignTable['u743'] = 'top';gv_vAlignTable['u291'] = 'top';gv_vAlignTable['u687'] = 'center';gv_vAlignTable['u284'] = 'top';document.getElementById('u97_img').tabIndex = 0;

u97.style.cursor = 'pointer';
$axure.eventManager.click('u97', function(e) {

if (true) {

	SetPanelVisibility('u472','','none',500);

}
});
gv_vAlignTable['u683'] = 'center';gv_vAlignTable['u280'] = 'top';gv_vAlignTable['u212'] = 'center';gv_vAlignTable['u237'] = 'center';gv_vAlignTable['u414'] = 'center';gv_vAlignTable['u424'] = 'center';gv_vAlignTable['u86'] = 'top';document.getElementById('u240_img').tabIndex = 0;

u240.style.cursor = 'pointer';
$axure.eventManager.click('u240', function(e) {

if (true) {

	SetPanelVisibility('u224','hidden','none',500);

}
});
gv_vAlignTable['u417'] = 'top';gv_vAlignTable['u233'] = 'top';gv_vAlignTable['u452'] = 'center';document.getElementById('u477_img').tabIndex = 0;

u477.style.cursor = 'pointer';
$axure.eventManager.click('u477', function(e) {

if (true) {

	SetPanelVisibility('u472','hidden','none',500);

}
});
gv_vAlignTable['u420'] = 'top';u445.tabIndex = 0;

u445.style.cursor = 'pointer';
$axure.eventManager.click('u445', function(e) {

if (true) {

	SetPanelState('u294', 'pd1u294','swing','down',500,'swing','down',500);

	SetPanelState('u311', 'pd5u311','none','',500,'none','',500);

}
});
gv_vAlignTable['u439'] = 'top';gv_vAlignTable['u660'] = 'top';gv_vAlignTable['u619'] = 'top';gv_vAlignTable['u41'] = 'top';gv_vAlignTable['u679'] = 'center';gv_vAlignTable['u47'] = 'top';gv_vAlignTable['u587'] = 'center';gv_vAlignTable['u184'] = 'top';gv_vAlignTable['u363'] = 'center';gv_vAlignTable['u583'] = 'top';gv_vAlignTable['u180'] = 'center';gv_vAlignTable['u112'] = 'top';gv_vAlignTable['u795'] = 'top';document.getElementById('u105_img').tabIndex = 0;

u105.style.cursor = 'pointer';
$axure.eventManager.click('u105', function(e) {

if (true) {

	SetPanelVisibility('u472','','none',500);

}
});
gv_vAlignTable['u324'] = 'top';u354.tabIndex = 0;

u354.style.cursor = 'pointer';
$axure.eventManager.click('u354', function(e) {

if (true) {

	SetPanelState('u294', 'pd2u294','swing','down',500,'swing','down',500);

	SetPanelState('u311', 'pd3u311','none','',500,'none','',500);

}
});
gv_vAlignTable['u140'] = 'center';gv_vAlignTable['u511'] = 'center';gv_vAlignTable['u317'] = 'center';gv_vAlignTable['u96'] = 'center';gv_vAlignTable['u90'] = 'center';gv_vAlignTable['u723'] = 'top';document.getElementById('u101_img').tabIndex = 0;

u101.style.cursor = 'pointer';
$axure.eventManager.click('u101', function(e) {

if (true) {

	SetPanelVisibility('u472','','none',500);

}
});
gv_vAlignTable['u345'] = 'center';gv_vAlignTable['u605'] = 'center';gv_vAlignTable['u532'] = 'top';gv_vAlignTable['u751'] = 'top';gv_vAlignTable['u557'] = 'top';gv_vAlignTable['u339'] = 'center';u558.tabIndex = 0;

u558.style.cursor = 'pointer';
$axure.eventManager.click('u558', function(e) {

if (true) {

	SetPanelVisibility('u536','hidden','none',500);

}
});
gv_vAlignTable['u13'] = 'top';gv_vAlignTable['u148'] = 'center';u519.tabIndex = 0;

u519.style.cursor = 'pointer';
$axure.eventManager.click('u519', function(e) {

if (true) {
function waitufc0bb016a2f64a90bb2fafa701dbcab71() {

	self.location.href=$axure.globalVariableProvider.getLinkUrl('Select_Consumption__A_.html');
}
setTimeout(waitufc0bb016a2f64a90bb2fafa701dbcab71, 300);

}
});
gv_vAlignTable['u772'] = 'top';gv_vAlignTable['u579'] = 'center';gv_vAlignTable['u759'] = 'top';gv_vAlignTable['u55'] = 'top';gv_vAlignTable['u296'] = 'center';gv_vAlignTable['u487'] = 'center';gv_vAlignTable['u463'] = 'top';gv_vAlignTable['u3'] = 'center';gv_vAlignTable['u367'] = 'center';gv_vAlignTable['u755'] = 'top';gv_vAlignTable['u695'] = 'top';gv_vAlignTable['u292'] = 'top';gv_vAlignTable['u689'] = 'center';gv_vAlignTable['u709'] = 'top';u217.tabIndex = 0;

u217.style.cursor = 'pointer';
$axure.eventManager.click('u217', function(e) {

if (true) {

	SetPanelVisibility('u622','','none',500);

}
});
gv_vAlignTable['u436'] = 'top';gv_vAlignTable['u80'] = 'top';gv_vAlignTable['u404'] = 'top';gv_vAlignTable['u498'] = 'top';u220.tabIndex = 0;

u220.style.cursor = 'pointer';
$axure.eventManager.click('u220', function(e) {

if (true) {

	SetPanelVisibility('u622','','none',500);

}
});
gv_vAlignTable['u245'] = 'center';gv_vAlignTable['u457'] = 'center';gv_vAlignTable['u676'] = 'top';gv_vAlignTable['u239'] = 'center';gv_vAlignTable['u273'] = 'top';document.getElementById('u644_img').tabIndex = 0;

u644.style.cursor = 'pointer';
$axure.eventManager.click('u644', function(e) {

if (true) {

	SetPanelVisibility('u622','hidden','none',500);

}
});
gv_vAlignTable['u20'] = 'center';gv_vAlignTable['u419'] = 'top';u21.tabIndex = 0;

u21.style.cursor = 'pointer';
$axure.eventManager.click('u21', function(e) {

if (true) {

	self.location.href=$axure.globalVariableProvider.getLinkUrl('Manage_User_Profile__A_.html');

}
});
gv_vAlignTable['u673'] = 'center';gv_vAlignTable['u739'] = 'top';document.getElementById('u479_img').tabIndex = 0;

u479.style.cursor = 'pointer';
$axure.eventManager.click('u479', function(e) {

if (true) {

	SetPanelVisibility('u472','hidden','none',500);

}
});
gv_vAlignTable['u643'] = 'center';gv_vAlignTable['u45'] = 'top';gv_vAlignTable['u387'] = 'center';gv_vAlignTable['u717'] = 'top';gv_vAlignTable['u788'] = 'top';gv_vAlignTable['u196'] = 'center';gv_vAlignTable['u786'] = 'top';u383.tabIndex = 0;

u383.style.cursor = 'pointer';
$axure.eventManager.click('u383', function(e) {

if (true) {

	SetPanelState('u294', 'pd0u294','swing','down',500,'swing','down',500);

	SetPanelState('u311', 'pd0u311','none','',500,'none','',500);

}
});
gv_vAlignTable['u797'] = 'center';gv_vAlignTable['u192'] = 'top';gv_vAlignTable['u124'] = 'top';gv_vAlignTable['u589'] = 'top';gv_vAlignTable['u38'] = 'top';
u117.style.cursor = 'pointer';
$axure.eventManager.click('u117', function(e) {

if (((GetCheckState('u111')) == (true)) || (((GetCheckState('u113')) == (true)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || (((GetCheckState('u121')) == (true)) || (((GetCheckState('u123')) == (true)) || (((GetCheckState('u125')) == (true)) || (((GetCheckState('u127')) == (true)) || ((GetCheckState('u129')) == (true))))))))))) {

	SetPanelVisibility('u483','','none',500);

}
else
if (((GetCheckState('u111')) == (false)) || (((GetCheckState('u113')) == (false)) || (((GetCheckState('u115')) == (false)) || (((GetCheckState('u117')) == (false)) || (((GetCheckState('u119')) == (false)) || (((GetCheckState('u121')) == (false)) || (((GetCheckState('u123')) == (true)) || (((GetCheckState('u125')) == (true)) || (((GetCheckState('u127')) == (true)) || ((GetCheckState('u129')) == (true))))))))))) {

	SetPanelVisibility('u483','hidden','none',500);

}
});
gv_vAlignTable['u707'] = 'top';gv_vAlignTable['u304'] = 'center';u523.tabIndex = 0;

u523.style.cursor = 'pointer';
$axure.eventManager.click('u523', function(e) {

if (true) {
function waitu8263349dccb34b40af951476307edc591() {

	self.location.href=$axure.globalVariableProvider.getLinkUrl('Take_Barcode__A_.html');
}
setTimeout(waitu8263349dccb34b40af951476307edc591, 300);

}
});
gv_vAlignTable['u398'] = 'top';gv_vAlignTable['u767'] = 'top';gv_vAlignTable['u120'] = 'top';gv_vAlignTable['u735'] = 'top';gv_vAlignTable['u705'] = 'top';gv_vAlignTable['u332'] = 'center';gv_vAlignTable['u357'] = 'center';gv_vAlignTable['u576'] = 'center';gv_vAlignTable['u358'] = 'top';gv_vAlignTable['u94'] = 'center';gv_vAlignTable['u763'] = 'center';gv_vAlignTable['u30'] = 'center';gv_vAlignTable['u731'] = 'top';gv_vAlignTable['u319'] = 'center';gv_vAlignTable['u538'] = 'center';gv_vAlignTable['u11'] = 'center';gv_vAlignTable['u70'] = 'top';u17.tabIndex = 0;

u17.style.cursor = 'pointer';
$axure.eventManager.click('u17', function(e) {

if (true) {

	self.location.href=$axure.globalVariableProvider.getLinkUrl('Help_Setting__A_.html');

}
});
gv_vAlignTable['u76'] = 'top';u559.tabIndex = 0;

u559.style.cursor = 'pointer';
$axure.eventManager.click('u559', function(e) {

if (true) {

	SetPanelState('u536', 'pd0u536','none','',500,'none','',500);

}
});
gv_vAlignTable['u35'] = 'top';gv_vAlignTable['u287'] = 'top';gv_vAlignTable['u729'] = 'top';gv_vAlignTable['u290'] = 'top';gv_vAlignTable['u1'] = 'center';gv_vAlignTable['u283'] = 'top';gv_vAlignTable['u489'] = 'center';gv_vAlignTable['u670'] = 'top';gv_vAlignTable['u607'] = 'center';gv_vAlignTable['u204'] = 'center';gv_vAlignTable['u85'] = 'top';gv_vAlignTable['u298'] = 'top';gv_vAlignTable['u667'] = 'center';gv_vAlignTable['u635'] = 'center';gv_vAlignTable['u232'] = 'top';document.getElementById('u257_img').tabIndex = 0;

u257.style.cursor = 'pointer';
$axure.eventManager.click('u257', function(e) {

if (true) {

	SetPanelVisibility('u248','hidden','none',500);

}
});
gv_vAlignTable['u476'] = 'top';gv_vAlignTable['u258'] = 'center';gv_vAlignTable['u84'] = 'top';u444.tabIndex = 0;

u444.style.cursor = 'pointer';
$axure.eventManager.click('u444', function(e) {

if (true) {

	SetPanelState('u294', 'pd2u294','swing','down',500,'swing','down',500);

	SetPanelState('u311', 'pd3u311','none','',500,'none','',500);

}
});
gv_vAlignTable['u663'] = 'top';gv_vAlignTable['u260'] = 'center';gv_vAlignTable['u631'] = 'top';u219.tabIndex = 0;

u219.style.cursor = 'pointer';
$axure.eventManager.click('u219', function(e) {

if (true) {

	SetPanelVisibility('u622','','none',500);

}
});
gv_vAlignTable['u438'] = 'top';gv_vAlignTable['u60'] = 'top';gv_vAlignTable['u279'] = 'top';gv_vAlignTable['u611'] = 'center';gv_vAlignTable['u66'] = 'top';gv_vAlignTable['u618'] = 'top';gv_vAlignTable['u459'] = 'center';u25.tabIndex = 0;

u25.style.cursor = 'pointer';
$axure.eventManager.click('u25', function(e) {

if (true) {

	self.location.href=$axure.globalVariableProvider.getLinkUrl('User_Application_Data__A_.html');

}
});
gv_vAlignTable['u306'] = 'top';gv_vAlignTable['u190'] = 'top';gv_vAlignTable['u395'] = 'center';gv_vAlignTable['u582'] = 'center';gv_vAlignTable['u389'] = 'center';
u111.style.cursor = 'pointer';
$axure.eventManager.click('u111', function(e) {

if (((GetCheckState('u111')) == (true)) || (((GetCheckState('u113')) == (true)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || (((GetCheckState('u121')) == (true)) || (((GetCheckState('u123')) == (true)) || (((GetCheckState('u125')) == (true)) || (((GetCheckState('u127')) == (true)) || ((GetCheckState('u129')) == (true))))))))))) {

	SetPanelVisibility('u483','','none',500);

}
else
if (((GetCheckState('u111')) == (false)) || (((GetCheckState('u113')) == (false)) || (((GetCheckState('u115')) == (false)) || (((GetCheckState('u117')) == (false)) || (((GetCheckState('u119')) == (false)) || (((GetCheckState('u121')) == (false)) || (((GetCheckState('u123')) == (true)) || (((GetCheckState('u125')) == (true)) || (((GetCheckState('u127')) == (true)) || ((GetCheckState('u129')) == (true))))))))))) {

	SetPanelVisibility('u483','hidden','none',500);

}
});
gv_vAlignTable['u794'] = 'center';gv_vAlignTable['u136'] = 'top';gv_vAlignTable['u507'] = 'center';gv_vAlignTable['u104'] = 'center';gv_vAlignTable['u323'] = 'top';gv_vAlignTable['u198'] = 'top';gv_vAlignTable['u567'] = 'top';gv_vAlignTable['u164'] = 'center';gv_vAlignTable['u535'] = 'center';gv_vAlignTable['u376'] = 'center';gv_vAlignTable['u747'] = 'top';gv_vAlignTable['u158'] = 'top';gv_vAlignTable['u563'] = 'top';gv_vAlignTable['u160'] = 'top';gv_vAlignTable['u531'] = 'top';gv_vAlignTable['u556'] = 'top';
u119.style.cursor = 'pointer';
$axure.eventManager.click('u119', function(e) {

if (((GetCheckState('u111')) == (true)) || (((GetCheckState('u113')) == (true)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || (((GetCheckState('u121')) == (true)) || (((GetCheckState('u123')) == (true)) || (((GetCheckState('u125')) == (true)) || (((GetCheckState('u127')) == (true)) || ((GetCheckState('u129')) == (true))))))))))) {

	SetPanelVisibility('u483','','none',500);

}
else
if (((GetCheckState('u111')) == (false)) || (((GetCheckState('u113')) == (false)) || (((GetCheckState('u115')) == (false)) || (((GetCheckState('u117')) == (false)) || (((GetCheckState('u119')) == (false)) || (((GetCheckState('u121')) == (false)) || (((GetCheckState('u123')) == (true)) || (((GetCheckState('u125')) == (true)) || (((GetCheckState('u127')) == (true)) || ((GetCheckState('u129')) == (true))))))))))) {

	SetPanelVisibility('u483','hidden','none',500);

}
});
gv_vAlignTable['u92'] = 'center';gv_vAlignTable['u372'] = 'top';gv_vAlignTable['u50'] = 'top';gv_vAlignTable['u769'] = 'top';gv_vAlignTable['u711'] = 'top';gv_vAlignTable['u56'] = 'top';u518.tabIndex = 0;

u518.style.cursor = 'pointer';
$axure.eventManager.click('u518', function(e) {

if (true) {

	SetPanelVisibility('u450','','none',500);

	SetPanelState('u450', 'pd1u450','swing','down',500,'swing','down',500);

}
});
gv_vAlignTable['u771'] = 'center';gv_vAlignTable['u8'] = 'center';u359.tabIndex = 0;

u359.style.cursor = 'pointer';
$axure.eventManager.click('u359', function(e) {

if (true) {

	SetPanelState('u294', 'pd0u294','swing','down',500,'swing','down',500);

	SetPanelState('u311', 'pd0u311','none','',500,'none','',500);

}
});
gv_vAlignTable['u15'] = 'center';gv_vAlignTable['u74'] = 'top';gv_vAlignTable['u75'] = 'top';document.getElementById('u486_img').tabIndex = 0;

u486.style.cursor = 'pointer';
$axure.eventManager.click('u486', function(e) {

if (true) {

	SetPanelVisibility('u533','','none',500);

SetCheckState('u111', false);

SetCheckState('u113', false);

SetCheckState('u115', false);

SetCheckState('u117', false);

SetCheckState('u119', false);

SetCheckState('u121', false);

SetCheckState('u123', false);

SetCheckState('u125', false);

SetCheckState('u127', false);

SetCheckState('u129', false);

}
});
gv_vAlignTable['u482'] = 'center';gv_vAlignTable['u289'] = 'top';
u121.style.cursor = 'pointer';
$axure.eventManager.click('u121', function(e) {

if (((GetCheckState('u111')) == (true)) || (((GetCheckState('u113')) == (true)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || (((GetCheckState('u121')) == (true)) || (((GetCheckState('u123')) == (true)) || (((GetCheckState('u125')) == (true)) || (((GetCheckState('u127')) == (true)) || ((GetCheckState('u129')) == (true))))))))))) {

	SetPanelVisibility('u483','','none',500);

}
else
if (((GetCheckState('u111')) == (false)) || (((GetCheckState('u113')) == (false)) || (((GetCheckState('u115')) == (false)) || (((GetCheckState('u117')) == (false)) || (((GetCheckState('u119')) == (false)) || (((GetCheckState('u121')) == (false)) || (((GetCheckState('u123')) == (true)) || (((GetCheckState('u125')) == (true)) || (((GetCheckState('u127')) == (true)) || ((GetCheckState('u129')) == (true))))))))))) {

	SetPanelVisibility('u483','hidden','none',500);

}
});
gv_vAlignTable['u527'] = 'center';gv_vAlignTable['u626'] = 'center';u223.tabIndex = 0;

u223.style.cursor = 'pointer';
$axure.eventManager.click('u223', function(e) {

if (true) {

	SetPanelVisibility('u224','','none',500);

}
});
gv_vAlignTable['u467'] = 'center';gv_vAlignTable['u254'] = 'center';gv_vAlignTable['u410'] = 'center';u216.tabIndex = 0;

u216.style.cursor = 'pointer';
$axure.eventManager.click('u216', function(e) {

if (true) {

	SetPanelVisibility('u622','','none',500);

}
});
gv_vAlignTable['u435'] = 'center';gv_vAlignTable['u403'] = 'center';gv_vAlignTable['u276'] = 'top';gv_vAlignTable['u647'] = 'center';gv_vAlignTable['u429'] = 'center';gv_vAlignTable['u615'] = 'top';gv_vAlignTable['u431'] = 'center';gv_vAlignTable['u675'] = 'top';document.getElementById('u238_img').tabIndex = 0;

u238.style.cursor = 'pointer';
$axure.eventManager.click('u238', function(e) {

if (true) {

	SetPanelVisibility('u224','hidden','none',500);

}
});
gv_vAlignTable['u609'] = 'center';gv_vAlignTable['u272'] = 'top';gv_vAlignTable['u40'] = 'top';gv_vAlignTable['u669'] = 'center';gv_vAlignTable['u46'] = 'top';gv_vAlignTable['u418'] = 'top';gv_vAlignTable['u478'] = 'center';gv_vAlignTable['u64'] = 'top';gv_vAlignTable['u727'] = 'top';u621.tabIndex = 0;

u621.style.cursor = 'pointer';
$axure.eventManager.click('u621', function(e) {

if (true) {

	SetPanelVisibility('u536','','none',500);

	SetPanelState('u536', 'pd0u536','none','',500,'none','',500);
function waituaf87f87d7d3d410eb0abf4f11b4fe7731() {

	SetPanelState('u536', 'pd1u536','none','',500,'none','',500);
function waitu0b53d15ad0664384af3efdad93374d891() {

	SetPanelState('u536', 'pd2u536','none','',500,'none','',500);
}
setTimeout(waitu0b53d15ad0664384af3efdad93374d891, 3000);
}
setTimeout(waituaf87f87d7d3d410eb0abf4f11b4fe7731, 3500);

}
});
gv_vAlignTable['u785'] = 'center';u382.tabIndex = 0;

u382.style.cursor = 'pointer';
$axure.eventManager.click('u382', function(e) {

if (true) {

	SetPanelState('u294', 'pd3u294','swing','down',500,'swing','down',500);

	SetPanelState('u311', 'pd4u311','none','',500,'none','',500);

}
});
document.getElementById('u99_img').tabIndex = 0;

u99.style.cursor = 'pointer';
$axure.eventManager.click('u99', function(e) {

if (true) {

	SetPanelVisibility('u472','','none',500);

}
});
gv_vAlignTable['u781'] = 'center';
u123.style.cursor = 'pointer';
$axure.eventManager.click('u123', function(e) {

if (((GetCheckState('u111')) == (true)) || (((GetCheckState('u113')) == (true)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || (((GetCheckState('u121')) == (true)) || (((GetCheckState('u123')) == (true)) || (((GetCheckState('u125')) == (true)) || (((GetCheckState('u127')) == (true)) || ((GetCheckState('u129')) == (true))))))))))) {

	SetPanelVisibility('u483','','none',500);

}
else
if (((GetCheckState('u111')) == (false)) || (((GetCheckState('u113')) == (false)) || (((GetCheckState('u115')) == (false)) || (((GetCheckState('u117')) == (false)) || (((GetCheckState('u119')) == (false)) || (((GetCheckState('u121')) == (false)) || (((GetCheckState('u123')) == (true)) || (((GetCheckState('u125')) == (true)) || (((GetCheckState('u127')) == (true)) || ((GetCheckState('u129')) == (true))))))))))) {

	SetPanelVisibility('u483','hidden','none',500);

}
});
gv_vAlignTable['u713'] = 'top';gv_vAlignTable['u310'] = 'top';gv_vAlignTable['u116'] = 'top';u335.tabIndex = 0;

u335.style.cursor = 'pointer';
$axure.eventManager.click('u335', function(e) {

if (true) {

	SetPanelState('u294', 'pd3u294','swing','down',500,'swing','down',500);

	SetPanelState('u311', 'pd4u311','none','',500,'none','',500);

}
});
gv_vAlignTable['u703'] = 'top';u522.tabIndex = 0;

u522.style.cursor = 'pointer';
$axure.eventManager.click('u522', function(e) {

if (true) {
function waituc9c637df753e421ea116ac26eb7544541() {

	self.location.href=$axure.globalVariableProvider.getLinkUrl('Take_Label__A_.html');
}
setTimeout(waituc9c637df753e421ea116ac26eb7544541, 300);

}
});
gv_vAlignTable['u176'] = 'top';gv_vAlignTable['u766'] = 'top';gv_vAlignTable['u329'] = 'top';gv_vAlignTable['u144'] = 'top';gv_vAlignTable['u515'] = 'center';gv_vAlignTable['u305'] = 'top';gv_vAlignTable['u138'] = 'center';gv_vAlignTable['u509'] = 'center';gv_vAlignTable['u172'] = 'center';gv_vAlignTable['u543'] = 'center';document.getElementById('u762_img').tabIndex = 0;

u762.style.cursor = 'pointer';
$axure.eventManager.click('u762', function(e) {

if (true) {

	SetPanelVisibility('u671','hidden','none',500);

}
});
u571.tabIndex = 0;

u571.style.cursor = 'pointer';
$axure.eventManager.click('u571', function(e) {

if (true) {

	SetPanelVisibility('u536','','none',500);

	SetPanelState('u536', 'pd0u536','none','',500,'none','',500);
function waitua77b4f50cf63431ab323e9733b6b344a1() {

	SetPanelState('u536', 'pd1u536','none','',500,'none','',500);
function waitu769d451791f244e297eed958209cdbd81() {

	SetPanelState('u536', 'pd2u536','none','',500,'none','',500);
}
setTimeout(waitu769d451791f244e297eed958209cdbd81, 3000);
}
setTimeout(waitua77b4f50cf63431ab323e9733b6b344a1, 3500);

}
});
gv_vAlignTable['u775'] = 'center';u378.tabIndex = 0;

u378.style.cursor = 'pointer';
$axure.eventManager.click('u378', function(e) {

if (true) {

	SetPanelState('u294', 'pd1u294','swing','down',500,'swing','down',500);

	SetPanelState('u311', 'pd5u311','none','',500,'none','',500);

}
});
gv_vAlignTable['u65'] = 'top';gv_vAlignTable['u54'] = 'top';gv_vAlignTable['u72'] = 'top';gv_vAlignTable['u286'] = 'top';gv_vAlignTable['u685'] = 'center';gv_vAlignTable['u282'] = 'top';document.getElementById('u89_img').tabIndex = 0;

u89.style.cursor = 'pointer';
$axure.eventManager.click('u89', function(e) {

if (true) {

	SetPanelVisibility('u472','','none',500);

}
});
gv_vAlignTable['u693'] = 'top';gv_vAlignTable['u267'] = 'top';gv_vAlignTable['u210'] = 'center';gv_vAlignTable['u235'] = 'center';gv_vAlignTable['u422'] = 'top';gv_vAlignTable['u447'] = 'center';gv_vAlignTable['u229'] = 'top';gv_vAlignTable['u231'] = 'top';gv_vAlignTable['u256'] = 'center';gv_vAlignTable['u443'] = 'top';gv_vAlignTable['u469'] = 'top';gv_vAlignTable['u630'] = 'top';u218.tabIndex = 0;

u218.style.cursor = 'pointer';
$axure.eventManager.click('u218', function(e) {

if (true) {

	SetPanelVisibility('u622','','none',500);

}
});
gv_vAlignTable['u471'] = 'top';gv_vAlignTable['u278'] = 'top';gv_vAlignTable['u649'] = 'center';gv_vAlignTable['u44'] = 'top';gv_vAlignTable['u681'] = 'center';gv_vAlignTable['u62'] = 'top';gv_vAlignTable['u186'] = 'center';document.getElementById('u464_img').tabIndex = 0;

u464.style.cursor = 'pointer';
$axure.eventManager.click('u464', function(e) {

if (true) {

	SetPanelState('u450', 'pd0u450','swing','up',500,'swing','up',500);
function waitu7b4b19df9e244549adbe4050b0ab65da1() {

	SetPanelVisibility('u450','hidden','none',500);
}
setTimeout(waitu7b4b19df9e244549adbe4050b0ab65da1, 1000);

}
});
gv_vAlignTable['u182'] = 'top';u16.tabIndex = 0;

u16.style.cursor = 'pointer';
$axure.eventManager.click('u16', function(e) {

if (true) {

	self.location.href=$axure.globalVariableProvider.getLinkUrl('Login.html');

}
});
document.getElementById('u107_img').tabIndex = 0;

u107.style.cursor = 'pointer';
$axure.eventManager.click('u107', function(e) {

if (true) {

	SetPanelVisibility('u472','','none',500);

}
});
gv_vAlignTable['u326'] = 'top';gv_vAlignTable['u513'] = 'center';gv_vAlignTable['u661'] = 'top';gv_vAlignTable['u725'] = 'top';gv_vAlignTable['u152'] = 'top';document.getElementById('u103_img').tabIndex = 0;

u103.style.cursor = 'pointer';
$axure.eventManager.click('u103', function(e) {

if (true) {

	SetPanelVisibility('u472','','none',500);

}
});
gv_vAlignTable['u322'] = 'top';gv_vAlignTable['u541'] = 'top';gv_vAlignTable['u347'] = 'top';gv_vAlignTable['u566'] = 'top';
u129.style.cursor = 'pointer';
$axure.eventManager.click('u129', function(e) {

if (((GetCheckState('u111')) == (true)) || (((GetCheckState('u113')) == (true)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || (((GetCheckState('u121')) == (true)) || (((GetCheckState('u123')) == (true)) || (((GetCheckState('u125')) == (true)) || (((GetCheckState('u127')) == (true)) || ((GetCheckState('u129')) == (true))))))))))) {

	SetPanelVisibility('u483','','none',500);

}
else
if (((GetCheckState('u111')) == (false)) || (((GetCheckState('u113')) == (false)) || (((GetCheckState('u115')) == (false)) || (((GetCheckState('u117')) == (false)) || (((GetCheckState('u119')) == (false)) || (((GetCheckState('u121')) == (false)) || (((GetCheckState('u123')) == (true)) || (((GetCheckState('u125')) == (true)) || (((GetCheckState('u127')) == (true)) || ((GetCheckState('u129')) == (true))))))))))) {

	SetPanelVisibility('u483','hidden','none',500);

}
});
document.getElementById('u93_img').tabIndex = 0;

u93.style.cursor = 'pointer';
$axure.eventManager.click('u93', function(e) {

if (true) {

	SetPanelVisibility('u472','','none',500);

}
});
gv_vAlignTable['u315'] = 'center';document.getElementById('u534_img').tabIndex = 0;

u534.style.cursor = 'pointer';
$axure.eventManager.click('u534', function(e) {

if (true) {

	SetPanelVisibility('u28','','none',500);

	BringToFront("u28");

	SetPanelVisibility('u483','hidden','none',500);

}
});
gv_vAlignTable['u753'] = 'top';gv_vAlignTable['u741'] = 'top';gv_vAlignTable['u350'] = 'top';gv_vAlignTable['u156'] = 'center';gv_vAlignTable['u309'] = 'top';gv_vAlignTable['u528'] = 'top';gv_vAlignTable['u369'] = 'center';gv_vAlignTable['u530'] = 'center';gv_vAlignTable['u118'] = 'top';gv_vAlignTable['u371'] = 'top';gv_vAlignTable['u773'] = 'top';gv_vAlignTable['u178'] = 'center';gv_vAlignTable['u768'] = 'top';gv_vAlignTable['u34'] = 'center';gv_vAlignTable['u52'] = 'top';gv_vAlignTable['u485'] = 'center';gv_vAlignTable['u321'] = 'center';gv_vAlignTable['u474'] = 'center';gv_vAlignTable['u226'] = 'center';gv_vAlignTable['u288'] = 'top';gv_vAlignTable['u228'] = 'center';gv_vAlignTable['u406'] = 'center';gv_vAlignTable['u252'] = 'center';u222.tabIndex = 0;

u222.style.cursor = 'pointer';
$axure.eventManager.click('u222', function(e) {

if (true) {

	SetPanelVisibility('u622','','none',500);

}
});
u247.tabIndex = 0;

u247.style.cursor = 'pointer';
$axure.eventManager.click('u247', function(e) {

if (true) {

	SetPanelVisibility('u248','','none',500);

}
});
document.getElementById('u466_img').tabIndex = 0;

u466.style.cursor = 'pointer';
$axure.eventManager.click('u466', function(e) {

if (true) {

	SetPanelState('u450', 'pd0u450','swing','up',500,'swing','up',500);
function waitu37666a09a7cd4798a2f212371ffd28341() {

	SetPanelVisibility('u450','hidden','none',500);
}
setTimeout(waitu37666a09a7cd4798a2f212371ffd28341, 1000);

}
});
gv_vAlignTable['u83'] = 'top';u215.tabIndex = 0;

u215.style.cursor = 'pointer';
$axure.eventManager.click('u215', function(e) {

if (true) {

	SetPanelVisibility('u622','','none',500);

}
});
gv_vAlignTable['u427'] = 'center';document.getElementById('u646_img').tabIndex = 0;

u646.style.cursor = 'pointer';
$axure.eventManager.click('u646', function(e) {

if ((GetPanelState('u651')) == ('pd0u651')) {

	SetPanelState('u651', 'pd3u651','none','',500,'none','',500);

}
else
if (((GetPanelState('u651')) != ('pd0u651')) && (((GetPanelState('u651')) != ('pd1u651')) && ((GetPanelState('u651')) != ('pd4u651')))) {

	SetPanelStatePrevious('u651',false,'none','',500,'none','',500);

}
else
if ((GetPanelState('u651')) == ('pd1u651')) {

	SetPanelState('u651', 'pd1u651','none','',500,'none','',500);

}
else
if ((GetPanelState('u651')) == ('pd4u651')) {

	SetPanelState('u651', 'pd0u651','none','',500,'none','',500);

}
});
gv_vAlignTable['u243'] = 'center';gv_vAlignTable['u269'] = 'top';gv_vAlignTable['u674'] = 'top';gv_vAlignTable['u271'] = 'top';document.getElementById('u642_img').tabIndex = 0;

u642.style.cursor = 'pointer';
$axure.eventManager.click('u642', function(e) {

if (true) {

	SetPanelVisibility('u622','hidden','none',500);

}
});
u449.tabIndex = 0;

u449.style.cursor = 'pointer';
$axure.eventManager.click('u449', function(e) {

if (true) {

	SetPanelState('u294', 'pd3u294','swing','down',500,'swing','down',500);

	SetPanelState('u311', 'pd4u311','none','',500,'none','',500);

}
});
gv_vAlignTable['u24'] = 'center';gv_vAlignTable['u162'] = 'center';gv_vAlignTable['u277'] = 'top';gv_vAlignTable['u42'] = 'top';gv_vAlignTable['u385'] = 'center';gv_vAlignTable['u194'] = 'center';gv_vAlignTable['u126'] = 'top';gv_vAlignTable['u150'] = 'top';gv_vAlignTable['u416'] = 'center';gv_vAlignTable['u749'] = 'top';gv_vAlignTable['u381'] = 'top';gv_vAlignTable['u313'] = 'center';gv_vAlignTable['u188'] = 'center';gv_vAlignTable['u593'] = 'center';document.getElementById('u500_img').tabIndex = 0;

u500.style.cursor = 'pointer';
$axure.eventManager.click('u500', function(e) {

if (true) {
function waitu290e7da95ef846a3a858271cd8582e371() {
}
setTimeout(waitu290e7da95ef846a3a858271cd8582e371, 2000);

}
});
gv_vAlignTable['u154'] = 'center';gv_vAlignTable['u525'] = 'center';gv_vAlignTable['u352'] = 'center';gv_vAlignTable['u122'] = 'top';gv_vAlignTable['u341'] = 'center';gv_vAlignTable['u737'] = 'top';
u115.style.cursor = 'pointer';
$axure.eventManager.click('u115', function(e) {

if (((GetCheckState('u111')) == (true)) || (((GetCheckState('u113')) == (true)) || (((GetCheckState('u115')) == (true)) || (((GetCheckState('u117')) == (true)) || (((GetCheckState('u119')) == (true)) || (((GetCheckState('u121')) == (true)) || (((GetCheckState('u123')) == (true)) || (((GetCheckState('u125')) == (true)) || (((GetCheckState('u127')) == (true)) || ((GetCheckState('u129')) == (true))))))))))) {

	SetPanelVisibility('u483','','none',500);

}
else
if (((GetCheckState('u111')) == (false)) || (((GetCheckState('u113')) == (false)) || (((GetCheckState('u115')) == (false)) || (((GetCheckState('u117')) == (false)) || (((GetCheckState('u119')) == (false)) || (((GetCheckState('u121')) == (false)) || (((GetCheckState('u123')) == (true)) || (((GetCheckState('u125')) == (true)) || (((GetCheckState('u127')) == (true)) || ((GetCheckState('u129')) == (true))))))))))) {

	SetPanelVisibility('u483','hidden','none',500);

}
});
u334.tabIndex = 0;

u334.style.cursor = 'pointer';
$axure.eventManager.click('u334', function(e) {

if (true) {

	SetPanelState('u294', 'pd0u294','swing','down',500,'swing','down',500);

	SetPanelState('u311', 'pd0u311','none','',500,'none','',500);

}
});
gv_vAlignTable['u553'] = 'top';gv_vAlignTable['u48'] = 'top';gv_vAlignTable['u302'] = 'top';u521.tabIndex = 0;

u521.style.cursor = 'pointer';
$axure.eventManager.click('u521', function(e) {

if (true) {
function waitub68a3a192827468b973c974c24bc69731() {

	self.location.href=$axure.globalVariableProvider.getLinkUrl('Take_Photo__A_.html');
}
setTimeout(waitub68a3a192827468b973c974c24bc69731, 300);

}
});
gv_vAlignTable['u328'] = 'center';document.getElementById('u91_img').tabIndex = 0;

u91.style.cursor = 'pointer';
$axure.eventManager.click('u91', function(e) {

if (true) {

	SetPanelVisibility('u472','','none',500);

}
});
gv_vAlignTable['u733'] = 'top';u330.tabIndex = 0;

u330.style.cursor = 'pointer';
$axure.eventManager.click('u330', function(e) {

if (true) {

	SetPanelState('u294', 'pd2u294','swing','down',500,'swing','down',500);

	SetPanelState('u311', 'pd3u311','none','',500,'none','',500);

}
});
gv_vAlignTable['u701'] = 'top';u355.tabIndex = 0;

u355.style.cursor = 'pointer';
$axure.eventManager.click('u355', function(e) {

if (true) {

	SetPanelState('u294', 'pd1u294','swing','down',500,'swing','down',500);

	SetPanelState('u311', 'pd5u311','none','',500,'none','',500);

}
});
gv_vAlignTable['u574'] = 'top';gv_vAlignTable['u761'] = 'top';gv_vAlignTable['u349'] = 'top';gv_vAlignTable['u568'] = 'top';gv_vAlignTable['u73'] = 'top';gv_vAlignTable['u629'] = 'center';u570.tabIndex = 0;

u570.style.cursor = 'pointer';
$axure.eventManager.click('u570', function(e) {

if (true) {

	SetPanelVisibility('u536','hidden','none',500);

}
});
gv_vAlignTable['u32'] = 'center';u764.tabIndex = 0;

u764.style.cursor = 'pointer';
$axure.eventManager.click('u764', function(e) {

if (true) {

	SetPanelVisibility('u671','hidden','none',500);

}
});
