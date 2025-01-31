
using Sodium;

namespace PSModule.Sodium.Isolated
{
    public static class PublicKeyBoxHelper
    {
        public static (byte[] PublicKey, byte[] PrivateKey) GenerateKeyPair()
        {
            return PublicKeyBox.GenerateKeyPair();
        }
    }
}
