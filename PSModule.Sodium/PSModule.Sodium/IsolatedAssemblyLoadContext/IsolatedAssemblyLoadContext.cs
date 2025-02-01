using System;
using System.Collections.Concurrent;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Runtime.Loader;

namespace PSModule.Sodium
{
    public class IsolatedAssemblyLoadContext : AssemblyLoadContext
    {
        private static readonly string s_psHome = Path.GetDirectoryName(Assembly.GetEntryAssembly().Location);

        private static readonly ConcurrentDictionary<string, IsolatedAssemblyLoadContext> s_isolatedLoadContexts = new ConcurrentDictionary<string, IsolatedAssemblyLoadContext>();

        internal static IsolatedAssemblyLoadContext GetForDirectory(string directoryPath)
        {
            return s_isolatedLoadContexts.GetOrAdd(directoryPath, (path) => new IsolatedAssemblyLoadContext(path));
        }

        private readonly string _isolatedDirPath;

        public IsolatedAssemblyLoadContext(string isolatedDirPath) : base(nameof(IsolatedAssemblyLoadContext))
        {
            _isolatedDirPath = isolatedDirPath;
        }

        protected override Assembly Load(AssemblyName assemblyName)
        {
            string assemblyFileName = $"{assemblyName.Name}.dll";

            // Make sure we allow other common PowerShell dependencies to be loaded by PowerShell
            // But specifically exclude Sodium.Core since we want to use our isolated version here
            if (!assemblyName.Name.Equals("Sodium.Core", StringComparison.OrdinalIgnoreCase))
            {
                string psHomeAsmPath = Path.Join(s_psHome, assemblyFileName);
                if (File.Exists(psHomeAsmPath))
                {
                    // With this API, returning null means nothing is loaded
                    return null;
                }
            }

            // Now try to load the assembly from the isolated directory
            string isolatedAsmPath = Path.Join(_isolatedDirPath, assemblyFileName);
            if (File.Exists(isolatedAsmPath))
            {
                WriteDebugMessage($"PSModule.Sodium.IsolatedAssemblyLoadContext is attempting to load Mmanaged DLL from path: {isolatedAsmPath}");
                return LoadFromAssemblyPath(isolatedAsmPath);
            }

            // else return null so that the default handler will resolve it
            return null;
        }

        protected override IntPtr LoadUnmanagedDll(string unmanagedDllName)
        {
            string platformFolder = GetPlatformFolder();
            string extension = GetPlatformExtension();
            string dllPath = Path.Combine(_isolatedDirPath, "runtimes", platformFolder, "native", unmanagedDllName + extension);

            if (dllPath != null)
            {
                if (File.Exists(dllPath))
                {
                    WriteDebugMessage($"PSModule.Sodium.IsolatedAssemblyLoadContext is attempting to load UNManaged DLL from path: {dllPath}");
                    return LoadUnmanagedDllFromPath(dllPath);
                }
            }

            return IntPtr.Zero;
        }

        private static string GetPlatformFolder()
        {
            if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
                return System.Environment.Is64BitProcess ? "win-x64" : "win-x86";
            if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
                return $"linux-{RuntimeInformation.OSArchitecture}".ToLower();
            if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
                return $"osx-{RuntimeInformation.OSArchitecture}".ToLower();
            throw new PlatformNotSupportedException("Unsupported platform");
        }

        private static string GetPlatformExtension()
        {
            if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
                return ".dll";
            if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
                return ".so";
            if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
                return ".dylib";
            throw new PlatformNotSupportedException("Unsupported platform");
        }

        /// <summary>
        /// Write debug message to console if SYSTEM_DEBUG or ACTIONS_STEP_DEBUG
        /// </summary>
        /// <param name="message"></param>
        private static void WriteDebugMessage(string message)
        {
            // SYSTEM_DEBUG is applicable to Azure DevOps pipelines
            // ACTIONS_STEP_DEBUG is applicable to GitHub step debug logging
            if (System.Environment.GetEnvironmentVariable("SYSTEM_DEBUG") == "True" || System.Environment.GetEnvironmentVariable("ACTIONS_STEP_DEBUG") == "true")
                Console.WriteLine(message);
        }
    }
}
