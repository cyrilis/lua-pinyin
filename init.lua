local dictionary = require("./data/hanzi")

local find, sub = string.find, string.sub

local split = function(str, sep, nmax)
    if sep == nil then
        sep = '%s+'
    end
    local r = { }
    if #str <= 0 then
        return r
    end
    local plain = false
    nmax = nmax or -1
    local nf = 1
    local ns = 1
    local nfr, nl = find(str, sep, ns, plain)
    while nfr and nmax ~= 0 do
        r[nf] = sub(str, ns, nfr - 1)
        nf = nf + 1
        ns = nl + 1
        nmax = nmax - 1
        nfr, nl = find(str, sep, ns, plain)
    end
    r[nf] = sub(str, ns)
    return r
end

local phoneticTable = {
    ["ā"] = "a1",
    ["á"] = "a2",
    ["ǎ"] = "a3",
    ["à"] = "a4",
    ["ē"] = "e1",
    ["é"] = "e2",
    ["ě"] = "e3",
    ["è"] = "e4",
    ["ō"] = "o1",
    ["ó"] = "o2",
    ["ǒ"] = "o3",
    ["ò"] = "o4",
    ["ī"] = "i1",
    ["í"] = "i2",
    ["ǐ"] = "i3",
    ["ì"] = "i4",
    ["ū"] = "u1",
    ["ú"] = "u2",
    ["ǔ"] = "u3",
    ["ù"] = "u4",
    ["ü"] = "v0",
    ["ǘ"] = "v2",
    ["ǚ"] = "v3",
    ["ǜ"] = "v4",
    ["ń"] = "n2",
    ["ň"] = "n3",
    [""] = "m2",
};

local accentMap = {
    ["à"] = "a",
    ["á"] = "a",
    ["ä"] = "a",
    ["â"] = "a",
    ["è"] = "e",
    ["é"] = "e",
    ["ë"] = "e",
    ["ê"] = "e",
    ["ì"] = "i",
    ["í"] = "i",
    ["ï"] = "i",
    ["î"] = "i",
    ["ò"] = "o",
    ["ó"] = "o",
    ["ö"] = "o",
    ["ô"] = "o",
    ["ù"] = "u",
    ["ú"] = "u",
    ["ü"] = "u",
    ["û"] = "u",
    ["ñ"] = "n",
    ["ç"] = "c",
    ["ā"] = "a1",
    ["ǎ"] = "a3",
    ["ē"] = "e1",
    ["ě"] = "e3",
    ["ō"] = "o1",
    ["ǒ"] = "o3",
    ["ī"] = "i1",
    ["ǐ"] = "i3",
    ["ū"] = "u1",
    ["ǔ"] = "u3",
    ["ü"] = "v0",
    ["ǘ"] = "v2",
    ["ǚ"] = "v3",
    ["ǜ"] = "v4",
    ["ń"] = "n2",
    ["ň"] = "n3",
    [""] = "m2",
}

function Utf8to32(utf8str)
    local bit
    if type(bit32) == "table" then
        bit = bit32
    end
    assert(type(utf8str) == "string")
    local res, seq, val = {}, 0, nil
    for i = 1, #utf8str do
        local c = string.byte(utf8str, i)
        if seq == 0 then
            table.insert(res, val)
            seq = c < 0x80 and 1 or c < 0xE0 and 2 or c < 0xF0 and 3 or
                    c < 0xF8 and 4 or --c < 0xFC and 5 or c < 0xFE and 6 or
                    error("invalid UTF-8 character sequence")
            val = bit.band(c, 2^(8-seq) - 1)
        else
            val = bit.bor(bit.lshift(val, 6), bit.band(c, 0x3F))
        end
        seq = seq - 1
    end
    table.insert(res, val)
    return res
end

function num2hex(num)
    local hexstr = '0123456789abcdef'
    local s = ''
    while num > 0 do
        local mod = math.fmod(num, 16)
        s = string.sub(hexstr, mod+1, mod+1) .. s
        num = math.floor(num / 16)
    end
    if s == '' then s = '0' end
    return s
end

function Pinyin (ustring, flat, keepNull)
    local stringArray = {}
    local tempAlphas = {}
    string.gsub(ustring, "([%z\1-\127\194-\244][\128-\191]*)", function(singleAlpha, b)

        if #singleAlpha == 2 then
            if accentMap[singleAlpha] then
                singleAlpha = accentMap[singleAlpha]
            end
        end
        if #singleAlpha > 1 then
            local hex = num2hex(Utf8to32(singleAlpha)[1])
            local pinyin = dictionary[hex]
            if #tempAlphas > 0 then
                table.insert(stringArray, table.concat(tempAlphas))
                tempAlphas = {}
            end
            if pinyin then
                pinyin = split(pinyin, ",")[1]
                if flat then
                    pinyin = pinyin:gsub("([%z\1-\127\194-\244][\128-\191]*)", function(phonetic)
                        if #phonetic > 1 then
                            return (phoneticTable[phonetic]):sub(0, 1)
                        else
                            return phonetic
                        end
                    end)
                end
                table.insert(stringArray, pinyin)
            else
                if keepNull then
                    table.insert(stringArray, "")
                end
            end
        else
            local hasEmptyStr = singleAlpha:find("[\n%s\t]")
            if hasEmptyStr and #tempAlphas > 0 then
                table.insert(stringArray, table.concat(tempAlphas))
                tempAlphas = {}
            else
                table.insert(tempAlphas, singleAlpha:lower())
            end
        end
    end)

    if #tempAlphas > 0 then
        table.insert(stringArray, table.concat(tempAlphas))
        tempAlphas = {}
    end

    return stringArray
end

-- print(table.concat(Pinyin("你好，世界！Hello World"), " "))
-- print(Pinyin("你好，世界！Hello World!", true))
-- print(table.concat(Pinyin("你好，世界！Hello World!", true), "-"))

-- Welcome
-- print(table.concat(Pinyin("汉语拼音"), " "))

if type(module) == "table" then
    module.exports = Pinyin
else
    return Pinyin
end
