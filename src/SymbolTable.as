
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
            Utf8UnicodeString[] unsplitStrings;
            unsplitStrings.Resize(3);
            unsplitStrings[0] = g_symbolsEmojiAndStandard;
            unsplitStrings[1] = g_symbolsFontAwesome47;
            unsplitStrings[2] = g_symbolsKenneyIcons;
            vec2 framePad = UI::GetStyleVarVec2(UI::StyleVar::FramePadding);
            float wrapLen = regionWidth - (framePad.x * 2.0f);

            for (uint symbolIndex = 0; symbolIndex < m_symbolStrings.Length; ++symbolIndex)
            {
                m_symbolStrings[symbolIndex] = "";
                int wrapPos = 0;
                while (wrapPos < int(unsplitStrings[symbolIndex].Length))
                {
                    wrapPos = UI::CalcWordWrapPosition(UI::GetFontSize(), tostring(unsplitStrings[symbolIndex]), wrapLen);
                    if (wrapPos >= int(unsplitStrings[symbolIndex].Length))
                    {
                        m_symbolStrings[symbolIndex] = tostring(unsplitStrings[symbolIndex]);
                        break;
                    }
                    else if (wrapPos > 4)
                    {
                        uint nextIndex = unsplitStrings[symbolIndex].GetNextCharacterIndex(wrapPos - 4);
                        m_symbolStrings[symbolIndex] += unsplitStrings[symbolIndex].Pop(nextIndex) + "\n";
                    }
                    else
                    {
                        break;
                    }
                }
            }
        }
    }
}
