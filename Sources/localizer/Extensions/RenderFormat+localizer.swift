import TranslationCatalogIO
import ArgumentParser

#if hasFeature(RetroactiveAttribute)
extension RenderFormat: @retroactive ExpressibleByArgument {}
#else
extension RenderFormat: ExpressibleByArgument {}
#endif
