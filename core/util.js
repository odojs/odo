function copyProperties(source, target) {
    var props = Object.getOwnPropertyNames(source);
    props.forEach(function(name) {
        var value = Object.getOwnPropertyDescriptor(source, name);
        Object.defineProperty(target, name, value);
    });
};

Object.defineProperty(Object.prototype, 'extend', {
    enumerable: false,
    value: function(from) {
        var result = {};
        copyProperties(this, result);
        copyProperties(from, result);
        return result;
    }
});