# UniversalAgent (Swift)

UniversalAgent je univerzalni Swift agent framework koji radi lokalno (iOS/macOS) i nudi:

- core agent loop (`UniversalAgent`) sa tools / tool-calls
- plug-in agente (`EducationAgent`, `AudioAgent`, `VisionAgent`)
- jednostavan RAG sloj za dokumente
- SwiftUI dashboard (`AgentDashboardView`) za profile, tools i sistemski prompt

## Kako dodati kao Swift Package

1. Otvori Xcode > `File > Add Packages...`
2. Kao source izaberi Git URL ovog repoa (kad ga pushuješ na GitHub)
3. Dodaj biblioteku `UniversalAgent` u svoj app target

## Osnovna upotreba (konceptualno)

- Napravi svoj `LLMClient` (MLX/Qwen, HTTP proxy, itd.)
- Napravi jednog od agenata (npr. `EducationAgent`, `AudioAgent`, `VisionAgent`) ili direktno `UniversalAgent`
- U SwiftUI koristi `AgentDashboardView(agent: ...)` kao kontrolni panel

