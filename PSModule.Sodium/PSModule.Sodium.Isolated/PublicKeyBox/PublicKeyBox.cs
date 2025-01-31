
using Sodium;

namespace PSModule.Sodium.Isolated
{
    public static class PublicKeyBox
    {
        public static (byte[] PublicKey, byte[] PrivateKey) GenerateKeyPair()
        {
            return PublicKeyBox.GenerateKeyPair();
        }
    }
}
