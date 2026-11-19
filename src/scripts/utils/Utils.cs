using Godot;
using System;
using System.Collections.Generic;
using System.Numerics;

namespace Utils
{
    public static class ProjectInfo
    {
        public static string GetVersion()
        {
            return ProjectSettings.GetSetting("application/config/version").ToString();
        }

        public static string GetVersionPretty()
        {
            string version = ProjectSettings.GetSetting("application/config/version").ToString();

            if (string.IsNullOrWhiteSpace(version))
            {
                GD.PushWarning("Version string in 'application/config/version' is empty");
                return "";
            }
            if (version.EndsWith("-prototype"))
            {
                return $"Prototype v{version.TrimSuffix("-prototype")}";
            }
            else if (version.EndsWith("-alpha"))
            {
                return $"Alpha v{version.TrimSuffix("-alpha")}";
            }
            else if (version.EndsWith("-beta"))
            {
                return $"Beta v{version.TrimSuffix("-beta")}";
            }
            else if (char.IsDigit(version[^1]))
            {
                return $"v{version}";
            }
            else
            {
                GD.PushWarning($"The version string '{version}' is not in the correct format, the correct format is:"
                    + "Major.Minor.Patch(-prototype | -alpha | -beta)"
                    );
                return "";
            }
        }
    }
}
