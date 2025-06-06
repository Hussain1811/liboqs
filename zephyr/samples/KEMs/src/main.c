// SPDX-License-Identifier: MIT

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Autogenerated header file from Zephyr containing the version number
#include <version.h>

#if KERNEL_VERSION_NUMBER >= 0x30500
#include <zephyr/random/random.h>
#else
#include <zephyr/random/rand32.h>
#endif

#include <oqs/oqs.h>


typedef struct magic_s {
	uint8_t val[31];
} magic_t;


void zephyr_randombytes(uint8_t *random_array, size_t bytes_to_read)
{
        // Obtain random bytes from the zephyr RNG
        sys_rand_get(random_array, bytes_to_read);
}


/* Displays hexadecimal strings */
static void OQS_print_hex_string(const char *label, const uint8_t *str, size_t len) {
	printf("%-20s (%4zu bytes):  ", label, len);
	for (size_t i = 0; i < (len); i++) {
		printf("%02X", str[i]);
	}
	printf("\n");
}

static OQS_STATUS kem_test_correctness(const char *method_name)
{
	OQS_KEM *kem = NULL;
	uint8_t *public_key = NULL;
	uint8_t *secret_key = NULL;
	uint8_t *ciphertext = NULL;
	uint8_t *shared_secret_e = NULL;
	uint8_t *shared_secret_d = NULL;
	OQS_STATUS rc, ret = OQS_ERROR;
	int rv;

	//The magic numbers are random values.
	//The length of the magic number was chosen to be 31 to break alignment
	magic_t magic;
	OQS_randombytes(magic.val, sizeof(magic_t));

	kem = OQS_KEM_new(method_name);
	if (kem == NULL) {
		fprintf(stderr, "ERROR: OQS_KEM_new failed\n");
		goto err;
	}

	printf("================================================================================\n");
	printf("Sample computation for KEM %s\n", kem->method_name);
	printf("================================================================================\n");

	public_key = malloc(kem->length_public_key + 2 * sizeof(magic_t));
	secret_key = malloc(kem->length_secret_key + 2 * sizeof(magic_t));
	ciphertext = malloc(kem->length_ciphertext + 2 * sizeof(magic_t));
	shared_secret_e = malloc(kem->length_shared_secret + 2 * sizeof(magic_t));
	shared_secret_d = malloc(kem->length_shared_secret + 2 * sizeof(magic_t));

	if ((public_key == NULL) || (secret_key == NULL) || (ciphertext == NULL) || (shared_secret_e == NULL) || (shared_secret_d == NULL)) {
		fprintf(stderr, "ERROR: malloc failed\n");
		goto err;
	}

	//Set the magic numbers before
	memcpy(public_key, magic.val, sizeof(magic_t));
	memcpy(secret_key, magic.val, sizeof(magic_t));
	memcpy(ciphertext, magic.val, sizeof(magic_t));
	memcpy(shared_secret_e, magic.val, sizeof(magic_t));
	memcpy(shared_secret_d, magic.val, sizeof(magic_t));

	public_key += sizeof(magic_t);
	secret_key += sizeof(magic_t);
	ciphertext += sizeof(magic_t);
	shared_secret_e += sizeof(magic_t);
	shared_secret_d += sizeof(magic_t);

	// and after
	memcpy(public_key + kem->length_public_key, magic.val, sizeof(magic_t));
	memcpy(secret_key + kem->length_secret_key, magic.val, sizeof(magic_t));
	memcpy(ciphertext + kem->length_ciphertext, magic.val, sizeof(magic_t));
	memcpy(shared_secret_e + kem->length_shared_secret, magic.val, sizeof(magic_t));
	memcpy(shared_secret_d + kem->length_shared_secret, magic.val, sizeof(magic_t));

	rc = OQS_KEM_keypair(kem, public_key, secret_key);
	if (rc != OQS_SUCCESS) {
		fprintf(stderr, "ERROR: OQS_KEM_keypair failed\n");
		goto err;
	}

	rc = OQS_KEM_encaps(kem, ciphertext, shared_secret_e, public_key);
	if (rc != OQS_SUCCESS) {
		fprintf(stderr, "ERROR: OQS_KEM_encaps failed\n");
		goto err;
	}

	rc = OQS_KEM_decaps(kem, shared_secret_d, ciphertext, secret_key);
	if (rc != OQS_SUCCESS) {
		fprintf(stderr, "ERROR: OQS_KEM_decaps failed\n");
		goto err;
	}

	rv = memcmp(shared_secret_e, shared_secret_d, kem->length_shared_secret);
	if (rv != 0) {
		fprintf(stderr, "ERROR: shared secrets are not equal\n");
		OQS_print_hex_string("shared_secret_e", shared_secret_e, kem->length_shared_secret);
		OQS_print_hex_string("shared_secret_d", shared_secret_d, kem->length_shared_secret);
		goto err;
	} else {
		printf("shared secrets are equal\n");
	}

	// test invalid encapsulation (call should either fail or result in invalid shared secret)
	OQS_randombytes(ciphertext, kem->length_ciphertext);
	rc = OQS_KEM_decaps(kem, shared_secret_d, ciphertext, secret_key);
	if (rc == OQS_SUCCESS && memcmp(shared_secret_e, shared_secret_d, kem->length_shared_secret) == 0) {
		fprintf(stderr, "ERROR: OQS_KEM_decaps succeeded on wrong input\n");
		goto err;
	}

	rv = memcmp(public_key + kem->length_public_key, magic.val, sizeof(magic_t));
	rv |= memcmp(secret_key + kem->length_secret_key, magic.val, sizeof(magic_t));
	rv |= memcmp(ciphertext + kem->length_ciphertext, magic.val, sizeof(magic_t));
	rv |= memcmp(shared_secret_e + kem->length_shared_secret, magic.val, sizeof(magic_t));
	rv |= memcmp(shared_secret_d + kem->length_shared_secret, magic.val, sizeof(magic_t));
	rv |= memcmp(public_key - sizeof(magic_t), magic.val, sizeof(magic_t));
	rv |= memcmp(secret_key - sizeof(magic_t), magic.val, sizeof(magic_t));
	rv |= memcmp(ciphertext - sizeof(magic_t), magic.val, sizeof(magic_t));
	rv |= memcmp(shared_secret_e - sizeof(magic_t), magic.val, sizeof(magic_t));
	rv |= memcmp(shared_secret_d - sizeof(magic_t), magic.val, sizeof(magic_t));
	if (rv != 0) {
		fprintf(stderr, "ERROR: Magic numbers do not match\n");
		goto err;
	}

	ret = OQS_SUCCESS;
	goto cleanup;

err:
	ret = OQS_ERROR;

cleanup:
	if ((secret_key) && (kem != NULL)) {
		OQS_MEM_secure_free(secret_key - sizeof(magic_t), kem->length_secret_key + 2 * sizeof(magic_t));
	}
	if ((shared_secret_e) && (kem != NULL)) {
		OQS_MEM_secure_free(shared_secret_e - sizeof(magic_t), kem->length_shared_secret + 2 * sizeof(magic_t));
	}
	if ((shared_secret_d) && (kem != NULL)) {
		OQS_MEM_secure_free(shared_secret_d - sizeof(magic_t), kem->length_shared_secret + 2 * sizeof(magic_t));
	}
	if (public_key) {
		OQS_MEM_insecure_free(public_key - sizeof(magic_t));
	}
	if (ciphertext) {
		OQS_MEM_insecure_free(ciphertext - sizeof(magic_t));
	}
	OQS_KEM_free(kem);

	return ret;
}


int main(void)
{
	OQS_STATUS rc;

	printf("Testing KEM algorithms using liboqs version %s\n", OQS_version());

	OQS_init();

	/* Set a RNG callback for Zephyr */
	OQS_randombytes_custom_algorithm(zephyr_randombytes);

	if (OQS_KEM_alg_count() == 0) {
		printf("No KEM algorithms enabled!\n");
		OQS_destroy();
		return EXIT_FAILURE;
	}

	for (int i = 0; i < OQS_KEM_alg_count(); i++) {
		const char *alg_name = OQS_KEM_alg_identifier(i);
		if (!OQS_KEM_alg_is_enabled(alg_name)) {
			printf("KEM algorithm %s not enabled!\n", alg_name);
		}
		else {
			rc = kem_test_correctness(alg_name);

			if (rc != OQS_SUCCESS) {
				OQS_destroy();
				return EXIT_FAILURE;
			}
		}
	}

	OQS_destroy();

	printf("Test done\n");

	return EXIT_SUCCESS;
}
