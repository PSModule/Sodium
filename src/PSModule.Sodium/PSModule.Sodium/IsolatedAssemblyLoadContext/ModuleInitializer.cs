using System;
using System.IO;
using System.Management.Automation;
using System.Reflection;
using System.Runtime.Loader;

namespace PSModule.Sodium
{
    public class ModuleInitializer : IModuleAssemblyInitializer
{
        private static string s_binBasePath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
        private static string s_binIsolatedPath = Path.Combine(s_binBasePath, "isolated");

        public void OnImport()
        {
            WriteDebugMessage("PSModule.Sodium.ModuleInitializer OnImport called.");
            WriteDebugMessage($"s_binBasePath: {s_binBasePath}");
            WriteDebugMessage($"s_binIsolatedPath: {s_binIsolatedPath}");
            AssemblyLoadContext.Default.Resolving += ResolveAssembly_NetCore;
        }

        private static Assembly ResolveAssembly_NetCore(
            AssemblyLoadContext assemblyLoadContext,
            AssemblyName assemblyName)
        {
            try
            {
                WriteDebugMessage($"PSModule.Sodium.ModuleInitializer ResolveAssembly_NetCore called for: {assemblyName}");

                // In .NET Core, PowerShell deals with assembly probing so our logic is much simpler
                // We only care about Sodium.Core and our .Isolated assembly
                if ( !assemblyName.Name.Equals("Sodium.Core") && !assemblyName.Name.EndsWith(".Isolated"))
                {
                    return null;
                }

                // Load Isolated assemblies through the isolated ALC, and let it resolve further dependencies automatically
                WriteDebugMessage($"PSModule.Sodium.ModuleInitializer is attempting to load Managed DLL: {assemblyName}");
                var isolatedAssemblyLoadContext = IsolatedAssemblyLoadContext.GetForDirectory(s_binIsolatedPath);
                WriteDebugMessage($"PSModule.Sodium.IsolatedAssemblyLoadContext created for directory: {s_binIsolatedPath}");
                var assembly = isolatedAssemblyLoadContext.LoadFromAssemblyName(assemblyName);
                WriteDebugMessage($"Assembly loaded: {assembly?.FullName ?? "null"}");
                return assembly;
            }
            catch (Exception ex)
            {
                WriteDebugMessage($"Exception in ResolveAssembly_NetCore: {ex.Message}");
                WriteDebugMessage(ex.StackTrace);
                throw;
            }
        }

        /// <summary>
        /// Write debug message to console if SYSTEM_DEBUG is set to true
        /// </summary>
        /// <param name="message"></param>
        private static void WriteDebugMessage(string message)
        {
            if (System.Environment.GetEnvironmentVariable("SYSTEM_DEBUG") == "True")
                Console.WriteLine(message);
        }
    }
}