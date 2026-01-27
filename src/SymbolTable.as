
namespace ColorPicker
{
    // Source: https://openplanet.dev/symbols
    Utf8UnicodeString g_symbolsEmojiAndStandard = "€ Ƀ ™ Ⓜ Ⓟ △ ⬜ ♢ ○ ◉ ◎ ✂ ✄ ✔ ✖ ✅ ✘ ❌ ♠ ♥ ♦ ♣ ♤ ♡ ♢ ♧ ≈ ∅ π — ‘ ’ “ ” † ‡ • … ‽ ⁂ № • ⏎ ⌫ ★ ☆ ☐ ☑ ☒ ☛ ☞ ✓ ✗ 〃 ⎘ ☍ ⎀ ⏰ ⏱ ⏲ ⏳ ⏴ ⏵ ⏶ ⏷ ⏸ ⏹ ⏺ 🔁 ☺ ⌨ ✎ ✍ ✉ ← ↑ → ↓ ↔ ↕ ⇄ ⇅ ↲ ↳ ↰ ↱ ↱ ⇤ ⇥ ↶ ↷ ↻ ⟳ ⟲ ➔ ↯ ↖ ➘ ➙ ➚ ➟ ⇠ ➤ ⇦ ⇨ ► ◀ ▲ ▼ ▷ ◁ △ ▽ ➴ ● 🔥 🔧 🔗 🕑 ♫ ♪ 🔊 💡 ❄ ⚑ 🔒 🔓 🔎 🎧 🌐 🎥 💾 🎮 🏃 🏆 🏁 💢 💿 📷 🔍 🔨 🔀 🔂 🔑 📎 👤 👥 🔔 🔕";
    Utf8UnicodeString g_symbolsFontAwesome47 = "                                                                                                                                                                                                                                                                                                                                                                    ";
    Utf8UnicodeString g_symbolsKenneyIcons = "                                                                                                                                                                        ";

    class SymbolTable
    {
        private string[] m_symbolStrings = {};
        private string[] m_symbolNames = {};
        private float m_lastContentWidth = 0.0f;

        SymbolTable()
        {
            m_symbolStrings.Resize(3);
            m_symbolStrings[0] = "";
            m_symbolStrings[1] = "";
            m_symbolStrings[2] = "";
            m_symbolNames.Resize(3);
            m_symbolNames[0] = "Emojis & standard symbols";
            m_symbolNames[1] = "Font Awesome 4.7";
            m_symbolNames[2] = "Kenney Icons";
        }

        void RenderInterface()
        {
            vec2 inputSize = UI::GetContentRegionAvail();
            inputSize.y = 0.0f;
            if (inputSize.x != m_lastContentWidth)
            {
                UpdateLineWrapPositions(inputSize.x);
            }
            m_lastContentWidth = inputSize.x;

            for (uint i = 0; i < m_symbolStrings.Length; ++i)
            {
                UI::Text(m_symbolNames[i]);
                UI::InputTextMultiline("##unicodetable" + tostring(i), m_symbolStrings[i], inputSize);
            }
        }

        private void UpdateLineWrapPositions(float regionWidth)
        {
            string[] unsplitStrings;
            unsplitStrings.Resize(3);
            unsplitStrings[0] = tostring(g_symbolsEmojiAndStandard);
            unsplitStrings[1] = tostring(g_symbolsFontAwesome47);
            unsplitStrings[2] = tostring(g_symbolsKenneyIcons);
            vec2 framePad = UI::GetStyleVarVec2(UI::StyleVar::FramePadding);
            float wrapLen = regionWidth - (framePad.x * 2.0f);

            for (uint symbolIndex = 0; symbolIndex < m_symbolStrings.Length; ++symbolIndex)
            {
                m_symbolStrings[symbolIndex] = "";
                while (true)
                {
                    // I think CalcWordWrapPosition was originally not unicode aware so I needed to overlay my Utf8
                    // string handlers ontop of it. It appears now that it will give me wrap positions that are not
                    // inside multibyte characters so lets just rely on that.
                    int wrapPos = UI::CalcWordWrapPosition(UI::GetFontSize(), unsplitStrings[symbolIndex], wrapLen);
                    if (wrapPos >= int(unsplitStrings[symbolIndex].Length))
                    {
                        m_symbolStrings[symbolIndex] += unsplitStrings[symbolIndex];
                        break;
                    }
                    else
                    {
                        m_symbolStrings[symbolIndex] += unsplitStrings[symbolIndex].SubStr(0, wrapPos) + "\n";
                        unsplitStrings[symbolIndex] = unsplitStrings[symbolIndex].SubStr(wrapPos);
                    }
                }
            }
        }
    }
}
