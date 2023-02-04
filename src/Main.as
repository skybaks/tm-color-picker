
vec3 g_pickedColor1 = vec3(1.0, 1.0, 1.0);
vec3 g_pickedColor2 = vec3(1.0, 1.0, 1.0);
string g_templateText = "Your Text Here";
string g_gradientText = "";

bool windowVisible = false;
ColorPicker::SymbolTable@ g_symbolTable = ColorPicker::SymbolTable();

string GradientCodedText(vec3 startColor, vec3 endColor, const string&in text)
{
    string result = "";
    ColorPicker::Utf8UnicodeString unicode = text;
    int letterCount = unicode.Length - 1;
    if (letterCount <= 0)
    {
        return result;
    }
    float xStep = (endColor.x - startColor.x) / letterCount;
    float yStep = (endColor.y - startColor.y) / letterCount;
    float zStep = (endColor.z - startColor.z) / letterCount;

    int currentLetter = 0;
    string lastColorCode = "";
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
    if (UI::MenuItem("\\$fa6" + Icons::PaintBrush + "\\$z Color Picker", "", windowVisible)) {
        windowVisible = !windowVisible;
    }
}

void RenderInterface()
{
    if (windowVisible)
    {
        UI::SetNextWindowSize(1100, 750);
        UI::Begin("Color Picker", windowVisible);

        g_templateText = UI::InputText("Input Text", g_templateText);
        UI::Separator();

        UI::PushID("Color1");
        UI::Text("\\$0f0Single Color\\$fff\n"
            + "Sets the input text to a single color.");
        g_pickedColor1 = UI::InputColor3("Pick Color", g_pickedColor1);
        string colorCode1 =
            DecimalToHex3(g_pickedColor1.x)
            + DecimalToHex3(g_pickedColor1.y)
            + DecimalToHex3(g_pickedColor1.z);
        string colorCodeText1 = "$" + colorCode1;
        UI::PushID("Color1CopyCode");
        if (UI::Button("Copy"))
        {
            IO::SetClipboard(colorCodeText1);
        }
        UI::SameLine();
        UI::InputText("Color Code", colorCodeText1);
        UI::PopID();
        string codedText1 = colorCodeText1 + g_templateText;
        UI::PushID("Color1CopyText");
        if (UI::Button("Copy"))
        {
            IO::SetClipboard(codedText1);
        }
        UI::SameLine();
        UI::InputText("Coded Text", codedText1);
        UI::PopID();
        UI::Text("Preview:\t" + codedText1.Replace("$", "\\$"));
        UI::PopID();

        UI::Separator();

        UI::PushID("Color2");
        UI::Text("\\$fffT\\$efew\\$dfdo "
            + "\\$cfcC\\$bfbo\\$afal\\$9f9o\\$8f8r "
            + "\\$7f7G\\$6f6r\\$5f5a\\$4f4d\\$3f3i\\$2f2e\\$1f1n\\$0f0t\\$fff\n"
            + "Sets the input text to a gradient between the first and second color.");
        g_pickedColor2 = UI::InputColor3("Pick Color", g_pickedColor2);
        string colorCode2 =
            DecimalToHex3(g_pickedColor2.x)
            + DecimalToHex3(g_pickedColor2.y)
            + DecimalToHex3(g_pickedColor2.z);
        string colorCodeText2 = "$" + colorCode2;
        UI::PushID("Color2CopyCode");
        if (UI::Button("Copy"))
        {
            IO::SetClipboard(colorCodeText2);
        }
        UI::SameLine();
        UI::InputText("Color Code", colorCodeText2);
        UI::PopID();
        UI::PushID("Color2CopyText");
        if (UI::Button("Copy"))
        {
            IO::SetClipboard(g_gradientText);
        }
        UI::SameLine();
        UI::InputText("Coded Text", g_gradientText);
        UI::PopID();
        UI::Text("Preview:\t" + g_gradientText.Replace("$", "\\$"));

        UI::PopID();

        if (UI::CollapsingHeader("Symbols"))
        {
            g_symbolTable.RenderInterface();
            UI::Separator();
        }

        UI::End();
    }
}

void Main()
{
    string lastTemplateText = "";
    vec3 lastColor1 = vec3(0.0, 0.0, 0.0);
    vec3 lastColor2 = vec3(0.0, 0.0, 0.0);

    while (true)
    {
        sleep(10);

        if (lastTemplateText != g_templateText
            || lastColor1.x != g_pickedColor1.x || lastColor1.y != g_pickedColor1.y || lastColor1.z != g_pickedColor1.z
            || lastColor2.x != g_pickedColor2.x || lastColor2.y != g_pickedColor2.y || lastColor2.z != g_pickedColor2.z)
        {
            g_gradientText = GradientCodedText(g_pickedColor1, g_pickedColor2, g_templateText);
        }

        lastTemplateText = g_templateText;
        lastColor1 = g_pickedColor1;
        lastColor2 = g_pickedColor2;
    }
}
