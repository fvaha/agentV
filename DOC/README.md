# UniversalAgent (Swift)

UniversalAgent is a local-first agent framework for iOS and macOS:

- core agent loop (`UniversalAgent`) with tools and tool-calls
- plug-in agents (`EducationAgent`, `AudioAgent`, `VisionAgent`)
- simple document RAG layer
- SwiftUI dashboard (`AgentDashboardView`) for profiles, tools and system prompt

## Adding as a Swift Package

1. Open Xcode and choose `File > Add Packages...`
2. Use the Git URL of this repository as the package source
3. Add the `UniversalAgent` library to your app target

## Basic usage (conceptual)

- Implement your own `LLMClient` (MLX/Qwen, HTTP proxy, etc.)
- Instantiate one of the domain agents (`EducationAgent`, `AudioAgent`, `VisionAgent`) or use `UniversalAgent` directly
- In SwiftUI, embed `AgentDashboardView(agent: ...)` as a control panel

---

UniversalAgent je lokalni agent framework za iOS i macOS:

- core agent loop (`UniversalAgent`) sa tools i tool-calls
- plug-in agenti (`EducationAgent`, `AudioAgent`, `VisionAgent`)
- jednostavan RAG sloj za dokumente
- SwiftUI dashboard (`AgentDashboardView`) za profile, tools i sistemski prompt

## Dodavanje kao Swift Package

1. Otvori Xcode i izaberi `File > Add Packages...`
2. Kao source postavi Git URL ovog repozitorija
3. Dodaj biblioteku `UniversalAgent` u svoj app target

## Osnovna upotreba

- Implementiraj svoj `LLMClient` (MLX/Qwen, HTTP proxy, itd.)
- Napravi jednog od agenata (`EducationAgent`, `AudioAgent`, `VisionAgent`) ili koristi `UniversalAgent` direktno
- U SwiftUI koristi `AgentDashboardView(agent: ...)` kao kontrolni panel

