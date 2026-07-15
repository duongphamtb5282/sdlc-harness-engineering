# Java / Spring Boot — Testing Pack

> **Pack ID:** `java-spring` | **Runner:** JUnit 5 + Mockito + Testcontainers

## Test pyramid

| Layer | Tool | Location |
|-------|------|----------|
| Unit | JUnit 5 + Mockito | `src/test/java/.../application/` |
| Slice | `@WebMvcTest`, `@DataJpaTest` | controller / repository slices |
| Integration | `@SpringBootTest` + Testcontainers | `*IT.java` or `integration/` |
| Contract | Spring Cloud Contract or OpenAPI diff | `src/test/resources/contracts/` |

## Commands

```bash
./gradlew test                    # all tests
./gradlew test --tests ClassName  # single class
./gradlew check                   # tests + checkstyle
./gradlew jacocoTestReport        # coverage
```

## Patterns

```java
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {
  @Mock OrderRepository repo;
  @InjectMocks OrderService service;

  @Test
  void createsOrder_whenValidRequest() { /* ... */ }
}

@SpringBootTest
@Testcontainers
class OrderApiIT {
  @Container static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16");

  @Test
  void postOrder_returns201() { /* MockMvc or RestTestClient */ }
}
```

## Coverage expectations

- New service methods: unit test per public method + happy + primary error path
- New endpoints: `@WebMvcTest` or integration test with auth headers
- Repositories with custom queries: `@DataJpaTest` with Testcontainers or H2 (prefer Testcontainers)

## QE receipt

Include: test count, failures (must be 0), coverage % if jacoco configured.
