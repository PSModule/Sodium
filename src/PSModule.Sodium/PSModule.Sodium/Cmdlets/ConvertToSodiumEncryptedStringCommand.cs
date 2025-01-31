using System;
using System.Text;
using System.Management.Automation;
using PSModule.Sodium.Isolated;

namespace PSModule.Sodium
{
    [Cmdlet(VerbsData.ConvertTo,"SodiumEncryptedString")]
    [OutputType(typeof(string))]
    public class ConvertToSodiumEncryptedStringCommand : PSCmdlet
    {
        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        public string Text { get; set; }

        [Parameter(
            Mandatory = true,
            Position = 1,
            ValueFromPipelineByPropertyName = true)]
        public string PublicKey { get; set; }

        protected override void ProcessRecord()
        {
            var byteArr = Encoding.UTF8.GetBytes(Text);
            var publicKey = Convert.FromBase64String(PublicKey);
            var sealedPublicKeyBox = SealedPublicKeyBoxHelper.Create(byteArr, publicKey);
            WriteObject(Convert.ToBase64String(sealedPublicKeyBox));
        }

    }
}
