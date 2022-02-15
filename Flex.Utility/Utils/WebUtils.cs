using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;

namespace Flex.Utility.Utils
{
    public class WebUtils
    {
        private const string AvailChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        private static Random random = new Random((int)DateTime.Now.Ticks);
        public static string UserPwd
        {
            get
            {
                var chars = Enumerable.Range(0, 6)
                                       .Select(x => AvailChars[random.Next(0, AvailChars.Length)]);
                return new string(chars.ToArray());
            }
        }

 

    }
}
