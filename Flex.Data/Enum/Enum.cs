using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Flex.Data.Enum
{
    public enum Type
    {
        New,
        Update
    }

    public enum PolicyType
    {
        PPP=01,
        TSP=02,
        ALM=03,
        INS=04
    }

    public enum ApprovalStatus
    {
        Pending,
        Approved,
        Disapproved,
        Processing,
        Canceled
    }

    public enum ClaimStatus
    {
        Pending,
        Approved,
        Disapproved,
        Processing,
        Canceled,
        Paid
    }

    public enum Category
    {
        NextofKin,
        Beneficiary
    }

    public enum Frequency
    {
        Monthly = 1,
        Quarterly,
        BiAnnually,
        Annually,
        Daily,
        Weekly
    }

    public enum RelationShip
    {
        Mother,
        Father,
        Daughther,
        Son,
        Brother,
        Sister,
        Husband,
        Wife,
        Others
    }
    public enum AuthStatus
    {
        FirstTime = 0,
        Normal = 1,
        Failed = 2,
        ForgotPassword = 3,
        PasswordExpired = 4,
        AlreadyLoggedOn = 5,
        Disabled = 6,
        DoesNotExist = 7,
        SuperAdminFailed = 8,
        AwaitingApproval = 9,
        Dormant = 10,
        LowTime = 11
    }
    public enum UserSessionStatus
    {
        Active = 1,
        Expired = 2,
        EndedByUser = 3,
        EndedUserRemote = 4,
        EndedBySecuritySystem = 5,
        Temporal = 6// temp session for such tasks as change password
    }
    public enum UserStatus
    {
        New = 0,
        Active = 1,
        Inactive = 2,
        AwaitingApproval = 3,
        Dormant = 4,
        Exited = 5
    }
    public enum Status : Int32
    {
        Inactive = 0,
        Active = 1,
        Exited=2
    }

    public enum LinkType
    {
        Portlet=0,
        Tab
    }

    public enum Instrument
    {
        RECEIPT = 0,
        PaymentVoucher,
        JournalVoucher,
        PL
    }

    //public enum PaymentChannel
    //{
    //    Cash=0,
    //    Cheque,
    //    BankDraft,
    //    Interswitch,
    //    GTB,
    //    NIP
    //}

    public enum PaymentMethod
    {
        Cash = 0,
        Cheque,
        BankDraft,
        Interswitch,
        GTB,
        NIP,
        Transfer,
        Teller
    }

    public enum AgentType
    {
        Marketer=0,
        Staff
    }

    public enum GroupClass
    {
        TRV,
        ER, 
        EE, 
        AVC, 
        CC, 
        PSC  
    }

    public enum SerialNoCountKey
    {
        QT,
        PY,
        RT,
        JV,
        PV,
        CM
    }

    public enum ReportFormat
    {
        pdf,
        xls
    }
    public enum TransactionStatus
    {
        Pending,
        Successful,
        Failed
    }

    public enum ClaimType
    {
        PartialWithdrawal,
        FullWithdrawal
    }

    public enum MessageType
    {
        PolicyCreation=1,
        Payment
    }

    public enum NotificationType
    {
        Email=1,
        Sms
    }
}
