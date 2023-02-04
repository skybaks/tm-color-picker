
namespace ColorPicker
{
    // Source: https://openplanet.dev/symbols
    Utf8UnicodeString g_symbolsEmojiAndStandard = "€ Ƀ ™ Ⓜ Ⓟ △ ⬜ ♢ ○ ◉ ◎ ✂ ✄ ✔ ✖ ✅ ✘ ❌ ♠ ♥ ♦ ♣ ♤ ♡ ♢ ♧ ≈ ∅ π — ‘ ’ “ ” † ‡ • … ‽ ⁂ № • ⏎ ⌫ ★ ☆ ☐ ☑ ☒ ☛ ☞ ✓ ✗ 〃 ⎘ ☍ ⎀ ⏰ ⏱ ⏲ ⏳ ⏴ ⏵ ⏶ ⏷ ⏸ ⏹ ⏺ 🔁 ☺ ⌨ ✎ ✍ ✉ ← ↑ → ↓ ↔ ↕ ⇄ ⇅ ↲ ↳ ↰ ↱ ↱ ⇤ ⇥ ↶ ↷ ↻ ⟳ ⟲ ➔ ↯ ↖ ➘ ➙ ➚ ➟ ⇠ ➤ ⇦ ⇨ ► ◀ ▲ ▼ ▷ ◁ △ ▽ ➴ ● 🔥 🔧 🔗 🕑 ♫ ♪ 🔊 💡 ❄ ⚑ 🔒 🔓 🔎 🎧 🌐 🎥 💾 🎮 🏃 🏆 🏁 💢 💿 📷 🔍 🔨 🔀 🔂 🔑 📎 👤 👥 🔔 🔕";
    Utf8UnicodeString g_symbolsFontAwesome47 = "                                                                                                                                                                                                                                                                                                                                                                    ";
    Utf8UnicodeString g_symbolsKenneyIcons = "                                                                                                                                                                        ";

    class SymbolTable
    {
        private string[] m_symbolStrings = { "", "", "" };
        private string[] m_symbolNames = { "Emojis & standard symbols", "Font Awesome 4.7", "Kenney Icons" };
        private float m_lastContentWidth = 0.0f;

        SymbolTable()
        {
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
                UI::InputTextMultiline("##" + tostring(i), m_symbolStrings[i], inputSize);
            }
        }

        private void UpdateLineWrapPositions(float regionWidth)
        {
            Utf8UnicodeString[] unsplitStrings = {
                tostring(g_symbolsEmojiAndStandard),
                tostring(g_symbolsFontAwesome47),
                tostring(g_symbolsKenneyIcons)
            };
            vec2 framePad = UI::GetStyleVarVec2(UI::StyleVar::FramePadding);
            float wrapLen = regionWidth - (framePad.x * 2.0f);

            for (uint symbolIndex = 0; symbolIndex < m_symbolStrings.Length; ++symbolIndex)
            {
                m_symbolStrings[symbolIndex] = "";
                uint wrapPos = 0;
                while (wrapPos < unsplitStrings[symbolIndex].Length)
                {
                    wrapPos = UI::CalcWordWrapPosition(2.05f, tostring(unsplitStrings[symbolIndex]), wrapLen);
                    if (wrapPos > 4)
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
