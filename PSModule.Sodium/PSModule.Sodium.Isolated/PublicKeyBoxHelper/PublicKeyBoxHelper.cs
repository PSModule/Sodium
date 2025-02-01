using Sodium;

namespace PSModule.Sodium.Isolated
{
    public static class PublicKeyBoxHelper
    {
        public static (byte[] PublicKey, byte[] PrivateKey) GenerateKeyPair()
        {
            var keyPair = PublicKeyBox.GenerateKeyPair();
            return (keyPair.PublicKey, keyPair.PrivateKey);
        }
    }
}
