
namespace ColorPicker
{
    // refs
    // https://www.unicode.org/versions/Unicode15.0.0/UnicodeStandard-15.0.pdf - Page 125, Table 3-6
    // https://www.ibm.com/docs/en/db2/11.5?topic=support-unicode-character-encoding
    class Utf8UnicodeString
    {
        private string m_string;
        private uint m_length;
        private uint m_lastIndexPos;
        private uint m_lastIndexCount;

        Utf8UnicodeString()
        {
            m_string = "";
            m_length = 0;
            m_lastIndexPos = 0;
            m_lastIndexCount = 0;
        }

        Utf8UnicodeString(const string&in str)
        {
            m_string = str;
            m_length = 0;
            m_lastIndexPos = 0;
            m_lastIndexCount = 0;
            CalculateLength();
        }

        string get_opIndex(uint index)
        {
            if (index > m_length)
            {
                throw("Index out of range");
            }

            string value = "";
            uint pos = GetIndexPos(index);
            uint byteCount = GetByteCount(m_string[pos]);
            if (byteCount > 0)
            {
                value = m_string.SubStr(pos, byteCount);
            }

            return value;
        }

        void set_opIndex(uint index, const string&in value)
        {
            if (index > m_length)
            {
                throw("Index out of range");
            }

            if (uint(value.Length) == 0)
            {
                throw("Empty string invalid for assignment");
            }

            if (uint(value.Length) != GetByteCount(value[0]))
            {
                throw("Invalid amount of bytes for assignment");
            }

            uint pos = GetIndexPos(index);
            uint currentByteCount = GetByteCount(m_string[pos]);
            if (uint(value.Length) == currentByteCount)
            {
                for (uint i = 0; i < uint(value.Length); ++i)
                {
                    m_string[pos+i] = value[i];
                }
            }
            else
            {
                m_string = m_string.SubStr(0, pos) + value + m_string.SubStr(pos + currentByteCount, m_string.Length - (pos + currentByteCount));
            }
        }

        uint get_Length()
        {
            return m_length;
        }

        string ToString()
        {
            return m_string;
        }

        Utf8UnicodeString@ opAssign(const string&in value)
        {
            m_string = value;
            CalculateLength();
            m_lastIndexPos = 0;
            m_lastIndexCount = 0;
            return this;
        }

        void Append(const string&in value)
        {
            m_string = m_string + value;
            CalculateLength();
        }

        void Insert(uint index, const string&in value)
        {
            if (index > m_length)
            {
                throw("Index out of range");
            }

            if (index == 0)
            {
                m_string = value + m_string;
                m_lastIndexCount = 0;
                m_lastIndexPos = 0;
            }
            else
            {
                uint pos = GetIndexPos(index);
                m_string = m_string.SubStr(0, pos) + value + m_string.SubStr(pos, m_string.Length - pos);
            }

            CalculateLength();
        }

        private void CalculateLength()
        {
            int search = 0;
            while(search < m_string.Length)
            {
                m_length += 1;
                search = GetNextIndex(search);
            }
        }

        private uint GetIndexPos(uint index)
        {
            uint pos = 0;
            uint count = 0;
            if (m_lastIndexCount < index)
            {
                pos = m_lastIndexPos;
                count = m_lastIndexCount;
            }

            while (count < index)
            {
                count += 1;
                pos = GetNextIndex(pos);
            }

            m_lastIndexPos = pos;
            m_lastIndexCount = count;

            return pos;
        }

        private uint GetNextIndex(uint start)
        {
            if (start < 0 || start > uint(m_string.Length))
            {
                return m_string.Length;
            }

            uint search = start;

            while (search < uint(m_string.Length))
            {
                uint byteCount = GetByteCount(m_string[search]);
                if (byteCount > 0)
                {
                    search += byteCount;
                    break;
                }
                else
                {
                    search += 1;
                }
            }

            return search;
        }

        private uint GetByteCount(uint8 byte)
        {
            uint count = 0;

            // 0xxx xxxx
            if ((byte & 0x80) == 0)
            {
                count = 1;
            }
            // 110y yyyy
            else if ((byte & 0xE0) == 0xC0)
            {
                count = 2;
            }
            // 1110 zzzz
            else if ((byte & 0xF0) == 0xE0)
            {
                count = 3;
            }
            // 1111 0uuu
            else if ((byte & 0xF8) == 0xF0)
            {
                count = 4;
            }
            // 10xx xxxx
            else if ((byte & 0xC0) == 0x80)
            {
                // error, within a word
                count = 0;
            }

            return count;
        }
    }
}
