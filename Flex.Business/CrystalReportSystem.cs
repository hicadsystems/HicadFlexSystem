using CrystalDecisions.CrystalReports.Engine;
using CrystalDecisions.ReportAppServer;
using Flex.Data.Enum;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace Flex.Business
{
    public class CrystalReportEngine : ReportEngine
    {
        override
        public IEnumerable GenerateReport(IEnumerable data)
        {
            ReportDocument reportDocument = null;
            //ReportClass rptH = new ReportClass();
            try
            {
                reportDocument = new ReportDocument();
                reportDocument.Load(ReportPath);
                Stream stream = null;

                //rptH.FileName = ReportName;
                //rptH.Load(ReportPath);
                reportDocument.SetDataSource(data);
                if (Parameter != null)
                {
                    foreach (var p in Parameter)
                    {
                        reportDocument.SetParameterValue(p.Key, p.Value);
                    }
                }
                if (reportFormat == ReportFormat.pdf)
                {
                    ReportDocument rrr = new ReportDocument();
                    //rrr.Load(Path.Combine(Server.MapPath("~//RDLCReport//CrystalReportAdvancementSummary.rpt")));
                    //rrr.SetDataSource(bsrCR);

                    //Response.Buffer = false;
                    //Response.ClearContent();
                    //Response.ClearHeaders();
                    //CrystalDecisions.Shared.ExportOptions exportOpts = rrr.ExportOptions;
                    //exportOpts.ExportFormatType = CrystalDecisions.Shared.ExportFormatType.PortableDocFormat;
                    //Stream stream = rrr.ExportToStream(exportOpts.ExportFormatType);
                    //stream.Seek(0, SeekOrigin.Begin);
                    //return File(stream, "application/pdf", "Batch Summary Report For Advancementt.pdf");
                    reportDocument.ExportToDisk(CrystalDecisions.Shared.ExportFormatType.PortableDocFormat,ReportName);
                }
                else
                {
                    stream = reportDocument.ExportToStream(CrystalDecisions.Shared.ExportFormatType.Excel);
                }
                streamProduct= stream;
                
                return null;
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error Occurred. Details {0}",ex.ToString());
                throw;
            }
            finally
            {
                reportDocument.Clone();
                reportDocument.Dispose();
                reportDocument = null;
            }
        }

        //public rptGratuity GenerateReport(rptGratuity data)
        //{
        //    ReportDocument reportDocument = null;
        //    //ReportClass rptH = new ReportClass();
        //    try
        //    {
        //        reportDocument = new ReportDocument();
        //        reportDocument.Load(ReportPath);
        //        Stream stream = null;

        //        //rptH.FileName = ReportName;
        //        //rptH.Load(ReportPath);
        //        reportDocument.SetDataSource(data);
        //        if (Parameter != null)
        //        {
        //            foreach (var p in Parameter)
        //            {
        //                reportDocument.SetParameterValue(p.Key, p.Value);
        //            }
        //        }
        //        if (reportFormat == ReportFormat.pdf)
        //        {
        //            ReportDocument rrr = new ReportDocument();
        //            //rrr.Load(Path.Combine(Server.MapPath("~//RDLCReport//CrystalReportAdvancementSummary.rpt")));
        //            //rrr.SetDataSource(bsrCR);

        //            //Response.Buffer = false;
        //            //Response.ClearContent();
        //            //Response.ClearHeaders();
        //            //CrystalDecisions.Shared.ExportOptions exportOpts = rrr.ExportOptions;
        //            //exportOpts.ExportFormatType = CrystalDecisions.Shared.ExportFormatType.PortableDocFormat;
        //            //Stream stream = rrr.ExportToStream(exportOpts.ExportFormatType);
        //            //stream.Seek(0, SeekOrigin.Begin);
        //            //return File(stream, "application/pdf", "Batch Summary Report For Advancementt.pdf");
        //            reportDocument.ExportToDisk(CrystalDecisions.Shared.ExportFormatType.PortableDocFormat, ReportName);
        //        }
        //        else
        //        {
        //            stream = reportDocument.ExportToStream(CrystalDecisions.Shared.ExportFormatType.Excel);
        //        }
        //        streamProduct = stream;

        //        return null;
        //    }
        //    catch (Exception ex)
        //    {
        //        Logger.InfoFormat("Error Occurred. Details {0}", ex.ToString());
        //        throw;
        //    }
        //    finally
        //    {
        //        reportDocument.Clone();
        //        reportDocument.Dispose();
        //        reportDocument = null;
        //    }
        //}
    }
}
