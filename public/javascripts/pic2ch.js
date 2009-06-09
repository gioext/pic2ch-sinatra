pic2ch = {
    isIE: /*@cc_on!@*/0,
    addEvent: function(elm, e, func) {
        if (elm.addEventListener) {
            elm.addEventListener(e, func, false);
        } else if (elm.attachEvent) {
            elm.attachEvent('on' + e, func);
        }
    },
    click: function(elm, func) {
        this.addEvent('click');       
    },
    load: function(elm, func) {
        this.addEvent('load');       
    }
};

pic2ch.$ = (function() {
    var _doc = document;
    return {
        s: function(id) {
            return _doc.getElementById(id);
        },
        c: function(tag) {
            return _doc.createElement(tag);
        }
    };
})();

pic2ch.addStar = (function(add, star, id, count) {
    var img10 = new Image();
    var img = new Image();

    return function(add, star, id, count, host) {
        img10.src = host + '/images/star10.gif';
        img.src = host + '/images/star.gif';
        var star10 = Math.floor(count / 10);
        var starn = count % 10;
        var estar = pic2ch.$.s(star);
        var eadd = pic2ch.$.s(add);

        eadd.onclick = function() {
            pic2ch.get('/star/' + id, function(){
                estar.appendChild(img.cloneNode(false));
                eadd.onclick = function() {}
            }); 
        };
        for (var i = 0; i < star10; i++) {
            estar.appendChild(img10.cloneNode(false));
        }
        for (var i = 0; i < starn; i++) {
            estar.appendChild(img.cloneNode(false));
        }
    }
})();

pic2ch.slideshow = (function() {
    var urls = [];
    var container;
    var parent_path;
    var position = -5;
    var cleft, cright, cimage, cthumbs, cthumb1, cthumb2, cthumb3, cthumb4, cthumb5;
    var overlay;
    var loading;
    var thumbs = {};

    var createUI = function() {
        container.innerHTML = '<div id="overlay"></div><div id="slide_left">◀</div><div id="slide_right">▶</div><div id="slide_image"></div><div id="loading"></div><div id="slide_thumbs"><div id="thumb1"></div><div id="thumb2"></div><div id="thumb3"></div><div id="thumb4"></div><div id="thumb5"></div></div>';
        cleft = pic2ch.$.s('slide_left');
        cright = pic2ch.$.s('slide_right');
        cimage = pic2ch.$.s('slide_image');
        cthumbs = pic2ch.$.s('slide_thumbs');
        thumbs.thumb1 = pic2ch.$.s('thumb1');
        thumbs.thumb2 = pic2ch.$.s('thumb2');
        thumbs.thumb3 = pic2ch.$.s('thumb3');
        thumbs.thumb4 = pic2ch.$.s('thumb4');
        thumbs.thumb5 = pic2ch.$.s('thumb5');
        overlay = pic2ch.$.s('overlay');
        loading = pic2ch.$.s('loading');

        cright.onclick = function() {
            pic2ch.slideshow.next();
        };
        cleft.onclick = function() {
            pic2ch.slideshow.prev();
        };
    };

    var showImage = function(n) {
        var m = position + n;
        if (m < 0) {
            position = urls.length + m;
        } else {
            position += n;
        }
        for (var i = 0; i < 5; i++) {
            var img = new Image();
            img.style.visibility = 'hidden';
            img.onload = (function(i, img) {
                return function() {
                    img.style.top = ((120 - img.height) / 2) + 'px';
                    img.style.left = ((120 - img.width) / 2) + 'px';
                    img.style.visibility = 'visible';
                }
            })(i, img);
            img.onclick = (function(i) {
                return function(){
                    overlay.style.visibility = 'visible';
                    loading.style.visibility = 'visible';
                    var img = new Image();
                    img.style.visibility = 'hidden';
                    img.onload = function() {
                        var w = img.width;
                        var h = img.height;
                        img.parentNode.style.marginTop = -(h / 2) + 'px';
                        img.parentNode.style.marginLeft = -(w / 2) + 'px';
                        img.style.visibility = 'visible';
                        cimage.style.visibility = 'visible';
                        loading.style.visibility = 'hidden';
                    };
                    img.onclick = function() {
                        cimage.style.visibility = 'hidden';
                        overlay.style.visibility = 'hidden';
                        cimage.removeChild(img);
                    };
                    cimage.appendChild(img);
                    img.src = path + '/pics3/' + id + '/' + urls[(position + i) % urls.length]; 
                }
            })(i);
            if (thumbs['now' + (i + 1)]) {
                thumbs['thumb' + (i + 1)].removeChild(thumbs['now' + (i + 1)]);
            }
            thumbs['thumb' + (i + 1)].appendChild(img);
            thumbs['now' + (i + 1)] = img;
            img.src = path + '/thumbs/' + id + '/' + urls[(position + i) % urls.length];
        }
    };

    return {
        init: function(settings) {
            urls = settings.urls || [];
            container = pic2ch.$.s(settings.container) || document;
            path = settings.path;
            id = settings.id;
            createUI();
            this.next();
        },
        next: function() {
            showImage(5);
        },
        prev: function() {
            showImage(-5);
        }
    };
})();
pic2ch.get = function(url, callback) {
    var req = null;
    try {
        if (window.XMLHttpRequest) {
            req = new XMLHttpRequest();
        } else if (window.ActiveXObject) {
            try {
                req = new ActiveXObject('Msxml2.XMLHTTP');
            } catch(e) {
                req = new ActiveXObject('Microsoft.XMLHTTP');
            }
        }
    } catch(e) {}
    if (!req) return;
    req.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
            callback(this.responseText);
        }
    };
    req.open('get', url, true);
    req.send(null);
};
