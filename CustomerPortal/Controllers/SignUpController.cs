using Flex.Business;
using Flex.Data.Enum;
using Flex.Data.Model;
using Flex.Data.Utility;
using Flex.Data.ViewModel;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace CustomerPortal.Controllers
{
    [AllowAnonymous]
    public class SignUpController : BaseController
    {
        // GET: SignUp
        public ActionResult Index()
        {
            GetReationShip();
            GetPolicyType();
            GetLocation();
            return View();
        }

        //public void Next(FormCollection form)
        //{
        //    try
        //    {
        //        var step = form["step"].ToString();

        //        switch (step)
        //        {
        //            case "1":
        //                BuildPersonal(form);
        //                break;
        //            case "2":
        //                BuildNextKin(form);
        //                break;
        //            default:
        //                break;
        //        }

        //    }
        //    catch (Exception ex)
        //    {
        //        Logger.ErrorFormat("Error Occurred. Details  [{0}--{1}]", ex.ToString(), ex.StackTrace);
        //        throw;
        //    }
        //}

        //private void BuildPersonal(FormCollection form)
        //{
        //    var newpolreg = new PesonalInfoBindingModel();

        //    newpolreg.Surname = form["Surname"].ToString();
        //    newpolreg.Othernames = form["OtherNames"].ToString();
        //    newpolreg.Phone = form["Phone"].ToString();
        //    newpolreg.Email = form["Email"].ToString();
        //    newpolreg.ResAddress = form["ResidentialAddress"].ToString();
        //    newpolreg.OfficeAddress = form["OfficeAddress"].ToString();
        //    newpolreg.PostalAddress = form["PostalAddress"].ToString();
        //    var dob = form["dob"].ToString();
        //    newpolreg.Dob = DateTime.ParseExact(dob,
        //                      "yyyy-MM-dd",
        //                       CultureInfo.InvariantCulture);
        //    newpolreg.Occupation = form["Occupation"].ToString();
        //    newpolreg.Amount = Convert.ToDecimal(form["Amount"].ToString());
        //    newpolreg.Frequency = form["contribFreq"].ToString();
        //    newpolreg.Duration = Convert.ToInt32(form["Duration"].ToString());
        //    newpolreg.Type = Flex.Data.Enum.Type.New;

        //    int poltye = 0;
        //    var ptype=form["policyType"].ToString();
        //    int.TryParse(ptype, out poltye);
        //    newpolreg.PolicyType = poltye;

        //    int loc = 0;
        //    var locatn = form["location"].ToString();
        //    int.TryParse(locatn, out loc);
        //    newpolreg.Location = loc;

        //    var signUpModel= new SignUpBindingModel();

        //    signUpModel.PersonalInfo=newpolreg;
        //    Session["SignUp"] = signUpModel;
        //}

        //private void BuildNextKin(FormCollection form)
        //{
        //    var nextofkinBen = new NextofKinBeneficiaryBindingModel();

        //    nextofkinBen.Name = form["Name"].ToString();
        //    nextofkinBen.Phone = form["Phone"].ToString();
        //    nextofkinBen.Address = form["Address"].ToString();
        //    nextofkinBen.Email = form["Email"].ToString();
        //    nextofkinBen.Category = Category.NextofKin;
        //    nextofkinBen.Type = Flex.Data.Enum.Type.New;
        //    var Nextdob = form["dob"].ToString();
        //    nextofkinBen.Dob = DateTime.ParseExact(Nextdob,
        //                      "yyyy-mm-dd",
        //                       CultureInfo.InvariantCulture);

        //    var nextofkinBenlist = new List<NextofKinBeneficiaryBindingModel>();

        //    //nextofkinBenlist = (List<NextofKinBeneficiaryBindingModel>)Session["beneficiaries"];

        //    nextofkinBenlist.Add(nextofkinBen);

        //    var signUpModel = Session["SignUp"] != null ? (SignUpBindingModel)Session["SignUp"] : new SignUpBindingModel();

        //    signUpModel.PersonalInfo.NextofKinBeneficiary = nextofkinBenlist;

        //    Session["SignUp"] = signUpModel;
        //}

        [HttpPost]
        public ActionResult SignUp(SignUpBindingModel signUpmodel)
        {
            Logger.Info("Inside post signUp");
            try
            {
                if (signUpmodel == null)
                {
                    throw new Exception("Error Occurred.");
                }
                if (signUpmodel.PersonalInfo == null)
                {
                    throw new Exception("Error occurred. Please try again");
                }
                if (signUpmodel.PersonalInfo.NextofKin==null)
                {
                    throw new Exception("Please Provide Next of kin Details");
                }
                if (signUpmodel.PersonalInfo.Beneficiary==null || !signUpmodel.PersonalInfo.Beneficiary.Any())
                {
                    throw new Exception("Please Provide atleast one Beneficiary");
                }
                new SignUpSystem(context).SaveSignUp(signUpmodel.PersonalInfo);
                //var ben = JsonConvert.DeserializeObject<List<NextofKinBeneficiaryBindingModel>>(beneficiaries);

                //if (ben.Any())
                //{
                //    ben.ForEach(x => x.Type = Flex.Data.Enum.Type.New);
                //    ben.ForEach(x => x.Category = Category.Beneficiary);


                //    var signUpData = (SignUpBindingModel)Session["SignUp"];
                //    if (signUpData==null)
                //    {
                //        throw new Exception("Session Time Out. Try Again");
                //    }
                //    if (signUpData.PersonalInfo.NextofKinBeneficiary!= null)
                //    {
                //        signUpData.PersonalInfo.NextofKinBeneficiary.AddRange(ben);
                //    }

                //    new SignUpSystem(context).SaveSignUp(signUpData.PersonalInfo);
                //}
                //else
                //{
                //    throw new Exception("Please Provide atleast one Beneficiary");
                //}

                
                return new JsonResult(){
                    Data= new UrlHelper(Request.RequestContext).Action("Success")
                };
                   
            }
            catch (Exception ex)
            {
                Logger.ErrorFormat("Error Occurred. Details  [{0}--{1}]", ex.ToString(), ex.StackTrace);
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult Success()
        {
            return View();
        }
        private void GetReationShip()
        {
            var relationships = UtilEnumHelper.GetEnumList(typeof(RelationShip));
            ViewBag.relationships = new SelectList(relationships, "ID", "Name");

        }

        public ActionResult Validate(string email,string phone)
        {
            try
            {
                var isValid = new PolicySystem(context).validate(email, phone);

                return new JsonResult()
                {
                    Data = isValid
                };
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Detail {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }
    }

}