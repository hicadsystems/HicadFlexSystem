using System;
using System.Collections.Generic;

namespace Flex.Data.Utility
{

    //Hay-Y 03-03-2015
    public class UtilEnumHelper
    {
        public static List<NameValueObj> GetEnumList(Type enumType)
        {
            if (enumType == null)
            {
                return new List<NameValueObj>();
            }

            var allValues = (int[])System.Enum.GetValues(enumType);
            var enumNames = System.Enum.GetNames(enumType);
            var myCollector = new List<NameValueObj>();

            try
            {
                for (var i = 0; i < allValues.GetLength(0); i++)
                {
                    var myObj = new NameValueObj { ID = allValues[i] };

                    if (enumNames[i].IndexOf("_", StringComparison.Ordinal) > -1)
                    {
                        enumNames[i] = enumNames[i].Replace("_", " ");
                    }
                    myObj.Name = enumNames[i];

                    myCollector.Add(myObj);
                }
            }
            catch (Exception)
            {
                return null;
            }

            return myCollector;
        }
    }

    public class NameValueObj
    {
        public Int32 ID { get; set; }

        public String Name { get; set; }
    }
}
