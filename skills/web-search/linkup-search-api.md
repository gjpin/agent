> ## Documentation Index
> Fetch the complete documentation index at: https://docs.linkup.so/llms.txt
> Use this file to discover all available pages before exploring further.

# /search

> The `/search` endpoint allows you to retrieve web content.

<Card title="Get your API key" icon="key" href="https://app.linkup.so" horizontal="True">
  Create a Linkup account for free to get your API key.
</Card>

The **`/search`** endpoint is a context retrieval tool for Web content. For a natural language query, it finds online information to ground your LLM's answer, along with sources.

<Tip>Our search is optimized for precision. Make sure to craft detailed prompts for optimal results. Learn more [here](../../../documentation/get-started/prompting).</Tip>

Depending on the `depth` parameter, results may be near-instant with no LLM processing (`fast`), fast while leveraging agentic search (`standard`), or slower but more comprehensive (`deep`).

If `outputType` is set to `structured`, you may provide a JSON `structuredOutputSchema` to dictate the response format.

<Tip>JSON formats are tricky. Learn more about structured output in [our guide](../../../documentation/tutorials/structured-output-guide).</Tip>

Learn more about these parameters in [Concepts](/pages/documentation/get-started/concepts).


## OpenAPI

````yaml https://api.linkup.so/v1/openapi.json POST /v1/search
openapi: 3.0.0
info:
  title: Linkup API
  description: >-
    Search the web in real time to get trustworthy, source-backed answers. Find
    the latest news and comprehensive results from the most relevant sources.
    Use natural language queries to quickly gather facts, citations, and
    context.
  version: '1.0'
  contact: {}
servers:
  - url: https://api.linkup.so
security: []
tags: []
paths:
  /v1/search:
    post:
      tags:
        - Search
      summary: /search
      description: The `/search` endpoint allows you to retrieve web content.
      operationId: search
      parameters: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/QuerySearchDto'
      responses:
        '200':
          content:
            searchResults:
              schema:
                $ref: '#/components/schemas/SearchResultsDto'
            sourcedAnswer:
              schema:
                $ref: '#/components/schemas/SourcedAnswerDto'
            structured:
              schema:
                description: >-
                  When you pick `structured` for the `outputType` parameter, you
                  will get the object corresponding to the JSON schema you used
                  in the `structuredOutputSchema` param.
                properties: {}
                type: object
            structuredWithSources:
              schema:
                $ref: '#/components/schemas/StructuredWithSourcesDto'
          description: Successful response
        '400':
          description: Bad Request - Invalid parameters
        '401':
          description: Unauthorized - Invalid or missing API key
        '402':
          description: >-
            Payment Required - No API key provided. Returns x402 payment details
            in the `payment-required` header for pay-per-request with USDC.
        '429':
          description: Too Many Requests - Rate limit exceeded or insufficient credits
      security:
        - bearer: []
components:
  schemas:
    QuerySearchDto:
      type: object
      properties:
        q:
          type: string
          description: >-
            The natural language question for which you want to retrieve
            context.
          example: What is Microsoft's 2024 revenue?
        structuredOutputSchema:
          type: string
          default: null
          description: >-
            Required only when `outputType` is `structured`. Provide a JSON
            schema (as a string) representing the desired response format. The
            root must be of type `object`.
          format: json
        includeSources:
          type: boolean
          default: false
          description: >-
            Relevant only when `outputType` is `structured`. Defines whether the
            response should include sources. **Please note that it modifies the
            schema of the response, see below**
        includeImages:
          type: boolean
          default: false
          description: Defines whether the API should include images in its results.
        fromDate:
          type: string
          default: null
          description: >-
            The date from which the search results should be considered, in ISO
            8601 format (YYYY-MM-DD). It must be before `toDate`, if provided,
            and later than 1970-01-01.
          example: '2025-01-01'
        toDate:
          type: string
          default: null
          description: >-
            The date until which the search results should be considered, in ISO
            8601 format (YYYY-MM-DD). It must be later than `fromDate`, if
            provided, or than 1970-01-01.
          example: '2025-01-01'
        includeDomains:
          description: >-
            The domains you want to search on. By default, don't restrict the
            search. You can provide up to 100 domains.
          example:
            - microsoft.com
            - agolution.com
          type: array
          items:
            type: string
        excludeDomains:
          description: >-
            The domains you want to exclude of the search. By default, don't
            restrict the search.
          example:
            - wikipedia.com
          type: array
          items:
            type: string
        includeInlineCitations:
          type: boolean
          default: false
          description: >-
            Relevant only when `outputType` is `sourcedAnswer`. Defines whether
            the answer should include inline citations.
        maxResults:
          type: number
          default: null
          description: >-
            The maximum number of results to return. The number of results will
            always be ≤ to maxResults.
        depth:
          type: string
          description: >-
            Defines the precision of the search. [BETA] `fast` is a sub-second
            search mode optimized for simple, focused queries; `standard`
            leverages agentic search to handle broader queries spanning multiple
            topics or sources, while remaining fast; `deep` leverages several
            iterations of agentic search to return comprehensive results,
            optimizing for coverage.
          enum:
            - deep
            - fast
            - standard
        outputType:
          type: string
          description: >-
            The type of output you want to get. Use `structured` for a
            custom-formatted response defined by `structuredOutputSchema`.
          enum:
            - searchResults
            - sourcedAnswer
            - structured
      required:
        - q
        - depth
        - outputType
    SearchResultsDto:
      type: object
      properties:
        results:
          type: array
          description: List of search results.
          items:
            oneOf:
              - $ref: '#/components/schemas/TextSearchResultDto'
              - $ref: '#/components/schemas/ImageSearchResultDto'
      required:
        - results
    SourcedAnswerDto:
      type: object
      properties:
        answer:
          type: string
          description: The answer to your question.
          example: >-
            Microsoft's revenue for fiscal year 2024 was $245.1 billion,
            reflecting a 16% increase from the previous year.
        sources:
          description: List of sources used to answer the question.
          example:
            - name: Microsoft 2024 Annual Report
              snippet: >-
                Highlights from fiscal year 2024 compared with fiscal year 2023
                included: Microsoft Cloud revenue increased 23% to $137.4
                billion.
              url: https://www.microsoft.com/investor/reports/ar24/index.html
          type: array
          items:
            $ref: '#/components/schemas/SourceDto'
      required:
        - answer
        - sources
    StructuredWithSourcesDto:
      type: object
      properties:
        data:
          type: object
          additionalProperties: true
          description: >-
            The object corresponding to the JSON schema you used in the
            `structuredOutputSchema` param.
        sources:
          type: array
          description: List of sources used to answer the question.
          items:
            properties:
              content:
                description: Extracted text content associated with the source.
                type: string
              name:
                description: The name or title of the source.
                type: string
              type:
                description: The type of the source.
                type: string
              url:
                description: The URL of the source.
                type: string
            type: object
      required:
        - data
        - sources
    TextSearchResultDto:
      type: object
      properties:
        type:
          type: string
          description: The type of the resource.
          enum:
            - text
          example: text
        name:
          type: string
          description: The title or name of the resource.
          example: Microsoft 2024 Annual Report
        url:
          type: string
          description: The URL of the resource.
          example: https://www.microsoft.com/investor/reports/ar24/index.html
          format: uri
        content:
          type: string
          description: Extracted text content associated with the resource.
          example: >-
            Highlights from fiscal year 2024 compared with fiscal year 2023
            included: Microsoft Cloud revenue increased 23% to $137.4 billion.
        favicon:
          type: string
          description: The favicon URL of the resource, if available.
          example: https://www.microsoft.com/favicon.ico
      required:
        - type
        - name
        - url
        - content
        - favicon
    ImageSearchResultDto:
      type: object
      properties:
        type:
          type: string
          description: The type of the resource.
          enum:
            - image
          example: image
        name:
          type: string
          description: The title or name of the resource.
          example: Microsoft Logo
        url:
          type: string
          description: The URL of the resource.
          example: https://example.com/microsoft-logo.png
          format: uri
      required:
        - type
        - name
        - url
    SourceDto:
      type: object
      properties:
        name:
          type: string
          description: The name or title of the source.
          example: Microsoft 2024 Annual Report
        url:
          type: string
          description: The URL of the source.
          example: https://www.microsoft.com/investor/reports/ar24/index.html
          format: uri
        snippet:
          type: string
          description: Extracted text content associated with the source.
          example: >-
            Highlights from fiscal year 2024 compared with fiscal year 2023
            included...
        favicon:
          type: string
          description: The favicon URL of the source, if available.
          example: https://www.microsoft.com/favicon.ico
          format: uri
      required:
        - name
        - url
        - snippet
        - favicon
  securitySchemes:
    bearer:
      scheme: bearer
      bearerFormat: JWT
      type: http

````
