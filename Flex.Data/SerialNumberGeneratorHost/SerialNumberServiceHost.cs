using SerialNumberGenerator.Service;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.ServiceModel;
using System.ServiceProcess;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
[assembly: log4net.Config.XmlConfigurator(Watch = true)]

namespace SerialNumberGeneratorHost
{
    partial class SerialNumberServiceHost : ServiceBase
    {
        public SerialNumberServiceHost()
        {
            InitializeComponent();
        }
        ServiceHost svcHost = null;

        protected override void OnStart(string[] args)
        {
            // TODO: Add code here to start your service.
            var logger = log4net.LogManager.GetLogger(this.GetType());
            // TODO: Add code here to start your service.
            try
            {
                if (ConfigurationManager.AppSettings["SleepInterval"] != null)
                {
                    Thread.Sleep(int.Parse(ConfigurationManager.AppSettings["SleepInterval"]));
                }
                logger.InfoFormat("Service Starting...");
                svcHost = new ServiceHost(typeof(SerialNumberService));
                svcHost.Open();
                logger.InfoFormat("Service is Running  at following address");
                foreach (var addy in svcHost.BaseAddresses)
                {
                    logger.InfoFormat("{0}", addy.AbsoluteUri);
                }
            }
            catch (Exception ex)
            {
                svcHost = null;
                logger.InfoFormat("Service can not be started. Error Message [" + ex.ToString() + "]");
            }
        }

        protected override void OnStop()
        {
            // TODO: Add code here to perform any tear-down necessary to stop your service.
        }
    }
}
