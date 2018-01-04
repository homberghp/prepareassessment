function getsnippet(domtarget, path) {
    var httpRequest;
    httpRequest = new XMLHttpRequest();
    if (!httpRequest) {
        return false;
    }

    httpRequest.onreadystatechange = function () {
        if (httpRequest.readyState === XMLHttpRequest.DONE) {
            if (httpRequest.status === 200) {
                var t = httpRequest.responseText;
                domtarget.innerHTML = t;
            }
        }
    };
    httpRequest.open('GET', 'getfile.php?path=' + path);
    httpRequest.send();
}
function getMySnippet() {

    var domtarget = document.getElementById("task-text");
    var sp;
    if (document.getElementById('complete').checked) {
        sp = 'taskpath';
    } else {
        sp = 'tasksnippetpath';
    }
    var path = document.getElementById(sp).value;//'harvest/snippets/TASK_1A_JAVA2/EXAM101.java.snippet.html';
    getsnippet(domtarget, path);
}