
class ColorCodeData
{
    vec3 Color;
    string Code;

    ColorCodeData(const vec3&in color, const string&in code)
    {
        Color = color;
        Code = code;
    }
}

array<ColorCodeData@> g_pickedColors = {};
string g_templateText = "Your Text Here";
string g_gradientText = "";
bool g_triggerRefresh = true;
bool g_windowVisible = false;

ColorPicker::SymbolTable@ g_symbolTable = ColorPicker::SymbolTable();

string N_GradientCodedText(array<vec3>@ colors, const string&in text)
{
    if (colors.Length <= 0)
    {
        return text;
    }
    else if (colors.Length == 1)
    {
        return "$" + Hex3ColorCode(colors[0]) + text;
    }

    ColorPicker::Utf8UnicodeString unicode = text;
    int letterCount = unicode.Length - 1;
    if (letterCount <= 0)
    {
        return text;
    }
    string result = "";
    int segmentLength = letterCount / Math::Max(1, colors.Length - 1);
    string lastColorCode = "";
    for (uint i = 0; i < colors.Length - 1; ++i)
    {
        string inputString = "";
        if (i < colors.Length - 2)
        {
            inputString = unicode.Pop(segmentLength);
        }
        else
        {
            inputString = unicode.ToString();
        }
        result += GradientCodedText(colors[i], colors[i + 1], inputString, lastColorCode);
        lastColorCode = Hex3ColorCode(colors[i]);
    }

    return result;
}

string GradientCodedText(vec3 startColor, vec3 endColor, const string&in text, const string&in initLastColorCode = "")
{
    string result = "";
    ColorPicker::Utf8UnicodeString unicode = text;
    int letterCount = unicode.Length - 1;
    if (letterCount <= 0)
    {
        return result;
    }
    if (initLastColorCode != "") { letterCount += 1; }
    float xStep = (endColor.x - startColor.x) / letterCount;
    float yStep = (endColor.y - startColor.y) / letterCount;
    float zStep = (endColor.z - startColor.z) / letterCount;

    int currentLetter = 0;
    if (initLastColorCode != "") { currentLetter += 1; }
    string lastColorCode = initLastColorCode;
    for (uint i = 0; i < unicode.Length; ++i)
    {
        string letter = unicode[i];

        string colorCode = 
            DecimalToHex3(startColor.x + (currentLetter * xStep))
            + DecimalToHex3(startColor.y + (currentLetter * yStep))
            + DecimalToHex3(startColor.z + (currentLetter * zStep));

        if (colorCode == lastColorCode
            || letter == " " || letter == "\t")
        {
            result += letter;
        }
        else
        {
            result += "$" + colorCode + letter;
        }
        lastColorCode = colorCode;
        currentLetter += 1;
    }

    return result;
}

string Hex3ColorCode(const vec3&in color)
{
    return DecimalToHex3(color.x) + DecimalToHex3(color.y) + DecimalToHex3(color.z);
}

string DecimalToHex3(float decimal)
{
    float value = Math::Round(decimal * 15.0);
    string strValue = "";
    if (value < 1.0)
        strValue = "0";
    else if (value < 10.0)
        strValue = "" + value;
    else if (value < 11.0)
        strValue = "a";
    else if (value < 12.0)
        strValue = "b";
    else if (value < 13.0)
        strValue = "c";
    else if (value < 14.0)
        strValue = "d";
    else if (value < 15.0)
        strValue = "e";
    else
        strValue = "f";
    return strValue;
}

void RenderMenu()
{
    if (UI::MenuItem("\\$fa6" + Icons::PaintBrush + "\\$z Color Picker", "", g_windowVisible)) {
        g_windowVisible = !g_windowVisible;
    }
}

void RenderInterface()
{
    if (g_windowVisible)
    {
        UI::SetNextWindowSize(1100, 750);
        UI::Begin("Color Picker", g_windowVisible);

        string newTemplateText = UI::InputText("Input Text", g_templateText);
        if (newTemplateText != g_templateText) { g_triggerRefresh = true; }
        g_templateText = newTemplateText;
        UI::Separator();

        for (uint i = 0; i < g_pickedColors.Length; ++i)
        {
            vec3 newColor = UI::InputColor3("Pick Color##" + tostring(i), g_pickedColors[i].Color);
            if (newColor != g_pickedColors[i].Color) { g_triggerRefresh = true; }
            g_pickedColors[i].Color = newColor;
            UI::SameLine();
            if (UI::Button("Copy##" + tostring(i)))
            {
                IO::SetClipboard(g_pickedColors[i].Code);
            }
            UI::SameLine();
            UI::InputText("##" + tostring(i), g_pickedColors[i].Code);
        }
        if (UI::Button("Add Color"))
        {
            g_pickedColors.InsertLast(ColorCodeData(vec3(1.0, 1.0, 1.0), ""));
            g_triggerRefresh = true;
        }
        UI::SameLine();
        UI::BeginDisabled(g_pickedColors.Length <= 1);
        if (UI::Button("Remove Color"))
        {
            if (g_pickedColors.Length > 1)
            {
                g_pickedColors.RemoveAt(g_pickedColors.Length - 1);
            }
            g_triggerRefresh = true;
        }
        UI::EndDisabled();

        if (UI::Button("Copy##CodedText"))
        {
            IO::SetClipboard(g_gradientText);
        }
        UI::SameLine();
        UI::InputText("##CodedText", g_gradientText);
        UI::Text("Preview:\t" + g_gradientText.Replace("$", "\\$"));

        UI::Separator();

        g_symbolTable.RenderInterface();

        UI::End();
    }
}

void Main()
{
    g_pickedColors.InsertLast(ColorCodeData(vec3(1.0, 1.0, 1.0), ""));

    while (true)
    {
        sleep(100);

        if (g_triggerRefresh)
        {
            g_triggerRefresh = false;
            array<vec3> colors = {};
            for (uint i = 0; i < g_pickedColors.Length; ++i)
            {
                colors.InsertLast(g_pickedColors[i].Color);
                g_pickedColors[i].Code = "$" + Hex3ColorCode(g_pickedColors[i].Color);
            }
            g_gradientText = N_GradientCodedText(colors, g_templateText);
        }
    }
}
