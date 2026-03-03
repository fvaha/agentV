import Foundation

public enum SystemToolNames {
    public static let listFiles = "list_files"
    public static let readFile = "read_file"
    public static let sendMail = "send_mail"
    public static let scheduleNotification = "schedule_notification"
    public static let listCalendarEvents = "list_calendar_events"
}

public enum SystemToolsFactory {
    public static func fileTools() -> [Tool] {
        [
            Tool(
                name: SystemToolNames.listFiles,
                description: "List files in a given directory path.",
                arguments: [
                    "path": .string
                ]
            ),
            Tool(
                name: SystemToolNames.readFile,
                description: "Read text contents of a file at a given path.",
                arguments: [
                    "path": .string
                ]
            )
        ]
    }

    public static func mailTools() -> [Tool] {
        [
            Tool(
                name: SystemToolNames.sendMail,
                description: "Send an email using the host application's mail capabilities.",
                arguments: [
                    "to": .array(.string),
                    "subject": .string,
                    "body": .string
                ]
            )
        ]
    }

    public static func notificationTools() -> [Tool] {
        [
            Tool(
                name: SystemToolNames.scheduleNotification,
                description: "Schedule a local notification.",
                arguments: [
                    "title": .string,
                    "body": .string,
                    "timeInterval": .double
                ]
            )
        ]
    }

    public static func calendarTools() -> [Tool] {
        [
            Tool(
                name: SystemToolNames.listCalendarEvents,
                description: "List upcoming calendar events in a time window.",
                arguments: [
                    "from": .string,
                    "to": .string
                ]
            )
        ]
    }
}

