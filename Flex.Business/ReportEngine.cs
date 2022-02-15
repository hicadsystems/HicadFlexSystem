using Flex.Data.Enum;
using log4net;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace Flex.Business
{
    public abstract class ReportEngine
    {
        public ILog Logger { get { return log4net.LogManager.GetLogger("Flex"); } }

        public abstract IEnumerable GenerateReport(IEnumerable data);

        public IEnumerable<KeyValuePair<String, String>> Parameter { get; set; }

        public byte[] ByteProduct;

        public Object ObjectProduct;

        public Stream streamProduct;

        public string ReportName;

        public string ReportPath;

        public ReportFormat reportFormat;

    }
}
