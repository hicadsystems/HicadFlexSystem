using System;
using System.Text;
using System.Security.Cryptography;


namespace Flex.Utility.Security
{
    /// <summary>
    /// Summary description for MD5Cryptograpghy.
    /// </summary>
    public class MD5Cryptograpghy
    {
        protected string ByteArrayToString(byte[] array)
        {

            StringBuilder output = new StringBuilder(array.Length);

            for (int index = 0; index < array.Length; index++)
            {
                output.Append(array[index].ToString("X2"));
            }
            return output.ToString();
        }

        public string ComputeHash(byte[] array)
        {
            return ByteArrayToString(new MD5CryptoServiceProvider().ComputeHash(array));
        }
        public string ComputeHash(System.IO.Stream inputStream)
        {
            return ByteArrayToString(new MD5CryptoServiceProvider().ComputeHash(inputStream));
        }
    }
}
