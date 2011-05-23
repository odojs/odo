// random numbers that look like GUIDs - http://stackoverflow.com/questions/105034/how-to-create-a-guid-uuid-in-javascript
function S4()   { return (((1+Math.random())*0x10000)|0).toString(16).substring(1); }
function guid() { return (S4()+S4()+"-"+S4()+"-"+S4()+"-"+S4()+"-"+S4()+S4()+S4()); }
var upload_uuid = undefined;


