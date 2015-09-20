#Lua Pinyin

A lua or luvit library for parse Chinese character into pinyin.

Pinyin dict data is from: https://github.com/hotoo/pinyin
## usage:
```
pinyin(STRING, FLAT)
```

**`STRING`** here is a Chinese character string like "你好世界"

**`FLAT`** is a boolean, when set to `true`, will ignore the tone of pinyin, eg: `"hàn yǔ pīn yīn"` will be `"han yu pin yin"`

output is a table.

## example:
```lua
local pinyin = require("path/to/pinyin");
print(table.concat(Pinyin("汉语拼音"), " "))
-- out put will be:
-- "hàn yǔ pīn yīn"
print(table.concat(Pinyin("汉语拼音", true), " "))
-- out put will be:
-- "han yu pin yin"
```

You can use it for generating url slug:
```lua
-- generate url slug with chinese title:
local slugify = function(title)
    return (table.concat(pinyin(title, true), "-"))
    :gsub("[^a-z0-9]", "-")
    :gsub("-+", '-') -- remove duplicated `-`
    :gsub("-$", "")
end

slugify("你好,世界!")
-- output: "ni-hao-shi-jie"

```

##todo
- [ ] Polyphonic character parse to increase accuracy [多音字]

## License

(The MIT License)

Copyright (c) 2015 Cyril Hou &lt;houshoushuai@gmail.com&gt;

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.