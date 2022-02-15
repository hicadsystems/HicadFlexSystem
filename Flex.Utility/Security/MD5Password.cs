using System;
using System.Text;
using System.Security.Cryptography;


namespace Flex.Utility.Security
{
    /// <summary>
    /// Summary description for MD5Password.
    /// </summary>
    public class MD5Password : MD5Cryptograpghy, IPasswordFactory
    {
        public MD5Password()
        {
            //
            // TODO: Add constructor logic here
            //
        }
        public string CreateSecurePassword(string clear)
        {
            byte[] clearBytes;
            byte[] computedHash;

            clearBytes = ASCIIEncoding.ASCII.GetBytes(clear);
            computedHash = new MD5CryptoServiceProvider().ComputeHash(clearBytes);

            return ByteArrayToString(computedHash);
        }
        public string GetPasswordInClear(string secure)
        {
            throw new Exception("One way encryption service");
        }

    }
}
